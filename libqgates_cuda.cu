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
