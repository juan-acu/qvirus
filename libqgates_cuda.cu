classify_global_multi_qubit_cuda_3q_optimized <- function(
  data_corr, 
  data_enc, 
  target, 
  threshold_grid = seq(-0.8, 0.8, by = 0.05),
  max_iter = 2000,
  loss_fn = c("simple", "balanced", "penalized"),
  num_hamiltonian_terms = 4,
  ranges
) {
  loss_fn <- match.arg(loss_fn)
  feature_names <- colnames(data_corr)
  num_patients <- nrow(data_enc)
  
  # Pre-calculation of rotation angles (CPU side)
  cat("Pre-calculating rotation angles...\n")
  precalc_angles <- do.call(rbind, lapply(1:num_patients, function(j) {
    as.numeric(encode_immunometabolic_record(data_enc[j, ], ranges))
  }))

  # Prepare Pauli Strings
  pauli_chars <- c("I", "X", "Y", "Z")
  pauli_terms_available <- apply(expand.grid(pauli_chars, pauli_chars, 
  pauli_chars), 1, paste, collapse="")
  pauli_terms_available <- pauli_terms_available[pauli_terms_available != "III"]

  # Tracking best model
  best_global_metrics <- list(balanced_acc = -Inf)
  best_hamiltonian_terms <- NULL

  for (i in 1:max_iter) {
    
    # --- 1. Structured Hamiltonian Construction ---
    # We create a list that mimics your former P_terms structure
    P_terms <- vector("list", num_hamiltonian_terms)
    selected_paulis <- sample(pauli_terms_available, num_hamiltonian_terms, 
    replace = FALSE)
    C_coeffs <- numeric(num_hamiltonian_terms)

    for (k in 1:num_hamiltonian_terms) {
      term <- selected_paulis[k]
      feature_pair <- sample(feature_names, 2, replace = FALSE)
      
      coeff <- cor(data_corr[[feature_pair[1]]], 
                   data_corr[[feature_pair[2]]], 
                   use = "complete.obs")
      
      # If correlation is NA, use a small random noise to keep the term active
      coeff <- ifelse(is.na(coeff), runif(1, -0.1, 0.1), coeff)

      P_terms[[k]] <- list(
        term = term,
        feature_pair = feature_pair,
        coefficient = coeff
      )
      C_coeffs[k] <- coeff
    }
    

    # --- 2. CUDA Scoring (Vectorized on GPU) ---
    scores <- unlist(lapply(1:num_patients, function(j) {
      # Fused Ansatz
      psi <- .Call("apply_full_ansatz_fused_cuda", 
                   precalc_angles[j, ], 
                   as.integer(3), 
                   PACKAGE="libqgates_cuda")
      
      # Batched Measurement (calculates sum(coeff_k * <P_k>) on GPU)
      patient_energy <- .Call("compute_hamiltonian_expectation_cuda", 
                               psi, 
                               selected_paulis, 
                               C_coeffs, 
                               PACKAGE = "libqgates_cuda")
      return(patient_energy)
    }))

    # --- 3. Evaluation ---
    current_metrics <- optimize_threshold_grid(scores, target, threshold_grid, 
    loss_fn)

    # --- 4. Store Best Results ---
    if (current_metrics$balanced_acc > best_global_metrics$balanced_acc) {
      best_global_metrics <- current_metrics
      best_global_metrics$iteration <- i
      best_hamiltonian_terms <- P_terms  # The crucial mapping update
      
      cat(sprintf("\nIter \%d | New Best B-Acc: \%.4f | Hamiltonian: \%s", 
                  i, best_global_metrics$balanced_acc, 
                  paste(selected_paulis, collapse=", ")))
    }
    
    if (i \%\% 50 == 0) cat(".")
  }
  
  return(list(
    metrics = best_global_metrics,
    best_hamiltonian_terms = best_hamiltonian_terms
  ))
}

normalize_angle <- function(val, range_vec, scale_factor = 2 * pi) {
  # range_vec should be c(min_val, max_val)
  min_v <- range_vec[1]
  max_v <- range_vec[2]
  
  # Avoid division by zero if max == min
  if (max_v == min_v) {
    return(0) 
  }
  
  # Clamp value to range to avoid out-of-bounds angles
  val_clamped <- max(min(val, max_v), min_v)
  
  # Min-Max Scaling -> Angle
  angle <- ((val_clamped - min_v) / (max_v - min_v)) * scale_factor
  
  return(angle)
}

encode_immunometabolic_record <- function(record, ranges) {

  theta1 <- normalize_angle(record[1], ranges[1:2])
  phi1   <- normalize_angle(record[2], ranges[3:4])
  
  theta2 <- normalize_angle(record[3], ranges[5:6]) 
  phi2   <- normalize_angle(record[4], ranges[7:8])
  
  theta3 <- normalize_angle(record[5], ranges[9:10])
  phi3   <- normalize_angle(record[6], ranges[11:12])
  
  return(data.frame(theta1, phi1, theta2, phi2, theta3, phi3))
}



// qgates_cuda.cu
// Compile to shared library:
// nvcc -Xcompiler -fPIC -shared -O3 --gpu-architecture=sm_61 \
//      -ccbin /usr/bin/g++-10                                \
//      -I/usr/share/R/include                                \
//      -o libqgates_cuda.so qgates_cuda.cu

#include <cuda_runtime.h>
#include <R.h>
#include <Rinternals.h>
#include <R_ext/Complex.h>

__global__ void apply_gate_kernel(double2* psi, int nbits, int target_msb_idx, 
double2 g00, double2 g01, double2 g10, double2 g11);
__global__ void apply_cgate_kernel(double2* psi, int nbits, int control_msb_idx, 
int target_msb_idx, double2 g00, double2 g01, double2 g10, double2 g11);

// --- Device complex ops using double2 ---
__device__ __forceinline__ double2 cmul(const double2 a, const double2 b) {
  return make_double2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}
__device__ __forceinline__ double2 cadd(const double2 a, const double2 b) {
  return make_double2(a.x + b.x, a.y + b.y);
}

// --- Kernel: apply a 2x2 single-qubit gate to target qubit ---
__global__ void apply_gate_kernel(double2* psi, int nbits, int target_msb_idx,
                                  double2 g00, double2 g01, double2 g10, 
                                  double2 g11) {

  int classical_bit_idx = nbits - target_msb_idx - 1;
  int stride = 1 << classical_bit_idx;
  int total = 1 << nbits;

  int groups = total >> (classical_bit_idx + 1); // total / (2*stride)
  int total_pairs = groups * stride;

  int pair_id = blockIdx.x * blockDim.x + threadIdx.x;
  if (pair_id >= total_pairs) return;

  int pairs_per_group = stride;
  int group = pair_id / pairs_per_group;
  int offset = pair_id \% pairs_per_group;

  int base = (group << (classical_bit_idx + 1)); // group * (2*stride)
  int i = base + offset;
  int j = i + stride;

  double2 psi_i = psi[i];
  double2 psi_j = psi[j];

  double2 t1 = cadd(cmul(g00, psi_i), cmul(g01, psi_j));
  double2 t2 = cadd(cmul(g10, psi_i), cmul(g11, psi_j));

  psi[i] = t1;
  psi[j] = t2;
}

// --- Kernel: apply a 2x2 single-qubit gate (U) to target qubit (TGT) 
//             ONLY if control qubit (CTL) is 1. ---
__global__ void apply_cgate_kernel(double2* psi, int nbits, 
                                   int control_msb_idx, int target_msb_idx,
                                   double2 g00, double2 g01, double2 g10, 
                                   double2 g11) {

    // 1. Map user-facing indices (MSB to LSB mapping)
    // The R code uses 0 for the most significant bit 
    int classical_ctl_idx = nbits - control_msb_idx - 1;
    int classical_tgt_idx = nbits - target_msb_idx - 1;

    // 2. Calculate stride/mask for the target qubit's bit flip
    int tgt_stride = 1 << classical_tgt_idx;
    // Mask to check if the control qubit is 1 in the index
    int ctl_mask = 1 << classical_ctl_idx; 

    int total = 1 << nbits;
    // We only process pairs where the control is 1.

    // 3. Threading calculation: We are applying the gate to 2^(nbits-2) pairs.
    // The total number of indices to check is 2^nbits.
    int pair_id = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Total number of pairs (where CTL=1) is total / 4 * 2 = total / 2
    // Specifically, (total / 2) is the number of states where CTL=1.
    // The number of *swapping pairs* is half of that: total / 4. 

    // Calculate effective indices to process: (2^nbits) / 4 = 2^(nbits-2) 
    
    // Iterate over the total number of 2x2 blocks in the 'CTL=1' subspace.
    // The total number of states where CTL=1 is (1 << (nbits - 1)).
    // Number TGT pairs in this subspace is (1 << (nbits - 2)) or total / 4.
    
    int num_pairs_to_process = total >> 2; // total / 4
    if (pair_id >= num_pairs_to_process) return;

    // The pair_id needs to mapped to the index 'i' where CTL=1 and TGT=0
    int i = 0;
    int current_pair = 0;
    
    // This part ensures coalesced memory access by iterating on the major bits
    // and correctly placing the control and target bits in the index 'i'. 
    
    // Since this is hard in a direct index calculation, we use a loop pattern 
    // over the 'unaffected' bits (nbits - 2), and then set CTL and TGT bits.
    
    // Stride is the 'physical' distance between i and j.
    // The total number of groups is 'total / (4 * stride_smallest)'. 
    // We will use a known CUDA pattern for this:

    // 4. Calculate the base index 'i' for the current thread/pair
    // The state index 'i' must satisfy: CTL=1 and TGT=0.
    
    // Calculate the total stride covering the target and control bits
    int total_stride_mask = ctl_mask | tgt_stride;
    int unaffected_mask = ~total_stride_mask;
    
    // The index 'i' is formed by:
    // 1. Setting the Control bit to 1: i |= ctl_mask
    // 2. Setting the Target bit to 0 (already done)
    // 3. Filling in the remaining bits from the pair_id
    
    // Simple block iteration (less memory efficient but simpler kernel logic):
    // The index 'i' must have the CTL bit set.
    // The index 'j' is i + tgt_stride.
    
    // Calculate the number of unaffected bits (nbits - 2)
    int shift = 0;
    if (classical_ctl_idx > classical_tgt_idx) {
        shift = classical_tgt_idx;
    } else {
        shift = classical_ctl_idx;
    }
    
    int loop_stride = total_stride_mask + 1; // 2^(max(ctl, tgt) + 1)
    
    // 'idx' iterates over the parts of the index *not* covered by CTL and TGT.
    // The index 'i' (where CTL=1, TGT=0) is computed by:
    // i = (pair_id \% stride) + ((pair_id / stride) * 2*stride) + ctl_mask
    
    int num_unaffected_bits = nbits - 2;
    int stride_unaffected = 1 << num_unaffected_bits;
    
    // To calculate 'i' and 'j' robustly from 'pair_id' without complex loops, 
    // we must rely on a known bit manipulation pattern for CNOT.
    
    // Simpler, but less optimal: Iterate over blocks that contain the CTL bit
    
    // Reverting to block calculation for clarity and safety:
    
    int pairs_per_subgroup = 1 << (nbits - 2); // 2^(nbits-2)
    
    // --- Optimized index calculation for C-U gate ---
    // The index 'i' must have the CTL bit set, and the TGT bit unset.
    // The loop iterates over all 2^(nbits-2) combinations of remaining bits.

    // 1. Calculate the 'i' index (CTL=1, TGT=0)
    int i_base = pair_id; // Initial value based on thread index
    
    // The 'unaffected' bits are all bits *except* CTL and TGT.
    // Insert 0 at the TGT bit position, and 1 at the CTL bit position.

    int ctl_shift = classical_ctl_idx;
    int tgt_shift = classical_tgt_idx;

    // Start with the pair_id (unaffected bits)
    int i_val = 0;
    int current_bit = 0;
    
    for (int k = 0; k < nbits; ++k) {
        if (k == ctl_shift) {
            i_val |= (1 << k); // Set CTL bit to 1
        } else if (k == tgt_shift) {
            // TGT bit is 0 (already set)
        } else {
            // Unaffected bits: take from pair_id
            if (pair_id & (1 << current_bit)) {
                i_val |= (1 << k);
            }
            current_bit++;
        }
    }
    
    i = i_val;
    int j = i + tgt_stride;
    
    // --- Application of the 2x2 transformation ---

    double2 psi_i = psi[i];
    double2 psi_j = psi[j];

    // t1 = g00*psi_i + g01*psi_j
    double2 t1 = cadd(cmul(g00, psi_i), cmul(g01, psi_j));
    // t2 = g10*psi_i + g11*psi_j
    double2 t2 = cadd(cmul(g10, psi_i), cmul(g11, psi_j));

    psi[i] = t1;
    psi[j] = t2;
}

extern "C" __attribute__((visibility("default")))
SEXP apply_full_ansatz_fused_cuda(SEXP paramsSEXP, SEXP nbitsSEXP) {
    int nbits = INTEGER(nbitsSEXP)[0];
    int total_states = 1 << nbits;
    double* params = REAL(paramsSEXP); // thetas, phis

    // 1. Initialize state vector on Host as |000>
    size_t bytes = total_states * sizeof(double2);
    double2* h_psi = (double2*)malloc(bytes);
    memset(h_psi, 0, bytes);
    h_psi[0] = make_double2(1.0, 0.0); // State |000>

    // 2. Allocate and Copy to Device
    double2* d_psi;
    cudaMalloc(&d_psi, bytes);
    cudaMemcpy(d_psi, h_psi, bytes, cudaMemcpyHostToDevice);

    // 3. Apply Gates sequentially on Device (No transfers in between!)
    // Rotation gates are constructed on the fly using the params
    for(int i = 0; i < 3; i++) {
        double theta = params[i*2];
        double phi = params[i*2 + 1];

        // RX Gate
        double2 rx00 = make_double2(cos(theta/2.0), 0);
        double2 rx01 = make_double2(0, -sin(theta/2.0));
        apply_gate_kernel<<<1, 256>>>(d_psi, nbits, i, rx00, rx01, rx01, rx00);
        
        // RY Gate
        double2 ry00 = make_double2(cos(phi/2.0), 0);
        double2 ry01 = make_double2(-sin(phi/2.0), 0);
        double2 ry10 = make_double2(sin(phi/2.0), 0);
        apply_gate_kernel<<<1, 256>>>(d_psi, nbits, i, ry00, ry01, ry10, ry00);
    }

    // CNOT Chain: 0->1, 1->2, 2->0
    double2 x00 = make_double2(0,0), x01 = make_double2(1,0);
    apply_cgate_kernel<<<1, 256>>>(d_psi, nbits, 0, 1, x00, x01, x01, x00);
    apply_cgate_kernel<<<1, 256>>>(d_psi, nbits, 1, 2, x00, x01, x01, x00);
    apply_cgate_kernel<<<1, 256>>>(d_psi, nbits, 2, 0, x00, x01, x01, x00);

    // 4. Copy back result to R
    SEXP res = PROTECT(allocVector(CPLXSXP, total_states));
    cudaMemcpy(h_psi, d_psi, bytes, cudaMemcpyDeviceToHost);
    for(int i = 0; i < total_states; i++) {
        COMPLEX(res)[i].r = h_psi[i].x;
        COMPLEX(res)[i].i = h_psi[i].y;
    }

    cudaFree(d_psi);
    free(h_psi);
    UNPROTECT(1);
    return res;
}

// New Kernel: Computes expectation value for a specific Pauli string configuration
__global__ void pauli_measurement_kernel(double2* psi, int nbits, int* masks, 
double* out_val) {
    extern __shared__ double sdata[];
    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int total = 1 << nbits;

    double val = 0.0;
    if (i < total) {
        // Calculate parity: only count bits where the Pauli operator is NOT 'I'
        int parity = 0;
        for (int q = 0; q < nbits; q++) {
            if (masks[q]) { 
                if ((i >> (nbits - q - 1)) & 1) parity++;
            }
        }
        double prob = psi[i].x * psi[i].x + psi[i].y * psi[i].y;
        val = (parity % 2 == 0) ? prob : -prob;
    }

    sdata[tid] = val;
    __syncthreads();

    // Standard reduction to sum values in the block
    for (unsigned int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) sdata[tid] += sdata[tid + s];
        __syncthreads();
    }
    if (tid == 0) atomicAdd(out_val, sdata[0]);
}

extern "C" __attribute__((visibility("default")))
SEXP compute_hamiltonian_expectation_cuda(SEXP psiSEXP, SEXP pauliSEXP, 
SEXP coeffsSEXP) {
    int nbits = 3;
    R_xlen_t len = XLENGTH(psiSEXP);
    double* coeffs = REAL(coeffsSEXP);
    int num_terms = length(pauliSEXP);
    
    size_t bytes = len * sizeof(double2);
    double2 *d_psi_ansatz, *d_psi_work;
    cudaMalloc(&d_psi_ansatz, bytes);
    cudaMalloc(&d_psi_work, bytes);
    
    // Copy Ansatz to Device
    Rcomplex* h_psi = COMPLEX(psiSEXP);
    double2* h_buf = (double2*)malloc(bytes);
    for(int k=0; k<len; k++) h_buf[k] = make_double2(h_psi[k].r, h_psi[k].i);
    cudaMemcpy(d_psi_ansatz, h_buf, bytes, cudaMemcpyHostToDevice);

    double total_expectation = 0.0;
    
    // Gate definitions
    double2 H00 = make_double2(1.0/sqrt(2.0), 0), 
    H01 = make_double2(1.0/sqrt(2.0), 0);
    double2 H10 = make_double2(1.0/sqrt(2.0), 0), 
    H11 = make_double2(-1.0/sqrt(2.0), 0);
    double2 SH00 = make_double2(1.0/sqrt(2.0), 0), 
    SH01 = make_double2(0, -1.0/sqrt(2.0));
    double2 SH10 = make_double2(0, -1.0/sqrt(2.0)), 
    SH11 = make_double2(1.0/sqrt(2.0), 0);

    // Device memory for the Pauli mask and temporary result
    int* d_masks;
    double* d_term_res;
    cudaMalloc(&d_masks, nbits * sizeof(int));
    cudaMalloc(&d_term_res, sizeof(double));

    for (int t = 0; t < num_terms; t++) {
        const char* p_str = CHAR(STRING_ELT(pauliSEXP, t));
        cudaMemcpy(d_psi_work, d_psi_ansatz, bytes, cudaMemcpyDeviceToDevice);
        
        int h_masks[3] = {0, 0, 0};
        for (int q = 0; q < nbits; q++) {
            if (p_str[q] == 'X') {
                apply_gate_kernel<<<1, 256>>>(d_psi_work, nbits, q, H00, H01, 
                H10, H11);
                h_masks[q] = 1;
            } else if (p_str[q] == 'Y') {
                apply_gate_kernel<<<1, 256>>>(d_psi_work, nbits, q, SH00, SH01, 
                SH10, SH11);
                h_masks[q] = 1;
            } else if (p_str[q] == 'Z') {
                h_masks[q] = 1;
            }
        }

        cudaMemset(d_term_res, 0, sizeof(double));
        cudaMemcpy(d_masks, h_masks, nbits * sizeof(int), 
        cudaMemcpyHostToDevice);
        
        // Measure the term expectation
        pauli_measurement_kernel<<<1, 256, 256 * sizeof(double)>>>(d_psi_work, 
        nbits, d_masks, d_term_res);
        
        double h_term_res;
        cudaMemcpy(&h_term_res, d_term_res, sizeof(double), 
        cudaMemcpyDeviceToHost);
        total_expectation += coeffs[t] * h_term_res;
    }

    cudaFree(d_psi_ansatz); cudaFree(d_psi_work);
    cudaFree(d_masks); cudaFree(d_term_res);
    free(h_buf);
    return ScalarReal(total_expectation);
}

