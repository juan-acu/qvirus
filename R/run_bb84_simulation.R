#' BB84 Quantum Key Distribution (QKD) Simulation
#'
#' Simulates the BB84 protocol for quantum key distribution (QKD), illustrating 
#' the difference in the Quantum Bit Error Rate (QBER) between an ideal channel 
#' (no interference) and a channel under eavesdropping (Eve). The simulation 
#' models the encoding, transmission, and measurement of quantum bits (qubits) 
#' following the original Bennett–Brassard (1984) protocol.
#'
#' @param eavesdropping_active Logical. If \code{TRUE}, the simulation includes 
#' an eavesdropper (Eve) who performs a measure-and-resend attack, introducing 
#' errors. If \code{FALSE}, the simulation runs under ideal, interference-free 
#' conditions. Default is \code{FALSE}.
#' @param key_length Integer. Length of the quantum key sequence to be 
#' simulated. The default is 1000, which provides good statistical stability.
#' @param test_ratio Numeric. Proportion (between 0 and 1) of bits that Alice 
#' and Bob compare to detect eavesdropping during the verification phase. 
#' Default is 0.2.
#' 
#' @return
#' A list of class \code{"BB84Simulation"} containing:
#' \describe{
#'   \item{\code{QBER}}{The observed Quantum Bit Error Rate between Alice's and Bob's bits.}
#'   \item{\code{Sifted_Length}}{Number of bits retained after basis reconciliation.}
#'   \item{\code{Final_Key_Length}}{Number of bits remaining after error testing.}
#'   \item{\code{Eavesdropping}}{Logical flag indicating whether eavesdropping was active.}
#' }
#'
#' @details
#' The BB84 protocol proceeds through the following stages:
#' \enumerate{
#'   \item \strong{Preparation:} Alice generates random bits and bases and encodes photons accordingly.
#'   \item \strong{Transmission:} Photons are sent over a quantum channel.
#'   \item \strong{Eavesdropping (optional):} Eve intercepts each photon, measures it using a random basis,
#'         and resends a new photon, introducing potential errors.
#'   \item \strong{Measurement:} Bob measures the incoming photons using his own random bases.
#'   \item \strong{Sifting:} Alice and Bob retain only bits measured with matching bases.
#'   \item \strong{Error estimation:} A random subset of the sifted bits is compared to estimate QBER.
#' }
#'
#' If the measured QBER exceeds a security threshold (commonly 15–25%), it indicates
#' that eavesdropping has occurred and the key must be discarded. In the absence of
#' interference, the QBER should be close to zero.
#'
#' @examples
#' # Scenario 1: Perfect Channel (No Eavesdropping)
#' results_no_eve <- run_bb84_simulation(eavesdropping_active = FALSE)
#' cat("--- Scenario 1: No Eavesdropping ---\n")
#' cat(paste("Sifted Key Length:", results_no_eve$Sifted_Length, "\n"))
#' cat(paste("Final Key Length:", results_no_eve$Final_Key_Length, "\n"))
#' cat(paste("Quantum Bit Error Rate (QBER):", round(results_no_eve$QBER * 100, 2), "%\n"))
#' cat("Result: Secure key established successfully.\n")
#'
#' # Scenario 2: Measure-and-Resend Attack
#' results_with_eve <- run_bb84_simulation(eavesdropping_active = TRUE)
#' cat("\n--- Scenario 2: With Eavesdropping ---\n")
#' cat(paste("Sifted Key Length:", results_with_eve$Sifted_Length, "\n"))
#' cat(paste("Final Key Length:", results_with_eve$Final_Key_Length, "\n"))
#' cat(paste("Quantum Bit Error Rate (QBER):", round(results_with_eve$QBER * 100, 2), "%\n"))
#'
#' if (results_with_eve$QBER > 0.15) {
#'   cat("High QBER detected. Eavesdropping likely — key discarded.\n")
#' } else {
#'   cat("No eavesdropping detected (unlikely in theory).\n")
#' }
#'
#' @references
#' Bennett, C. H., & Brassard, G. (1984).
#' \emph{Quantum cryptography: Public key distribution and coin tossing.}
#' Proceedings of IEEE International Conference on Computers, Systems and Signal Processing, 175–179.
#'
#' Nielsen, M. A., & Chuang, I. L. (2010).
#' \emph{Quantum Computation and Quantum Information.} Cambridge University Press.
#'
#' Rieffel, E. G., & Polak, W. H. (2011).
#' \emph{Quantum Computing: A Gentle Introduction.} MIT Press.
#'
#' @export
run_bb84_simulation <- function(eavesdropping_active = FALSE,
                                key_length = 1000,
                                test_ratio = 0.2) {
  alice_encode <- function(bit, base) {
    list(encoded_bit = bit, encoding_base = base)
  }
  
  # --- Alice genera bits y bases ---
  alice_bits <- sample(0:1, key_length, replace = TRUE)
  alice_bases <- sample(0:1, key_length, replace = TRUE)
  photons_sent <- mapply(alice_encode, alice_bits, alice_bases, SIMPLIFY = FALSE)
  original_alice_bits <- alice_bits
  
  # --- Ataque de Eve ---
  if (eavesdropping_active) {
    eve_bases <- sample(0:1, key_length, replace = TRUE)
    for (i in seq_len(key_length)) {
      a_info <- photons_sent[[i]]
      eve_base <- eve_bases[i]
      eve_bit <- if (a_info$encoding_base == eve_base) a_info$encoded_bit else sample(0:1, 1)
      photons_sent[[i]] <- list(encoded_bit = eve_bit, encoding_base = eve_base)
    }
  }
  
  # --- Bob mide los fotones ---
  bob_bases <- sample(0:1, key_length, replace = TRUE)
  bob_bits <- rep(NA, key_length)
  
  for (i in seq_len(key_length)) {
    photon <- photons_sent[[i]]
    bob_base <- bob_bases[i]
    bob_bits[i] <- if (photon$encoding_base == bob_base) photon$encoded_bit else sample(0:1, 1)
  }
  
  # --- Fase de Tamizado ---
  matching <- which(alice_bases == bob_bases)
  raw_key_alice <- original_alice_bits[matching]
  raw_key_bob <- bob_bits[matching]
  
  sifted_length <- length(raw_key_alice)
  test_size <- floor(sifted_length * test_ratio)
  test_indices <- sample(seq_len(sifted_length), test_size)
  
  # --- Cálculo del QBER ---
  errors <- sum(raw_key_alice[test_indices] != raw_key_bob[test_indices])
  error_rate <- errors / test_size
  
  secret_indices <- setdiff(seq_len(sifted_length), test_indices)
  final_key_length <- length(secret_indices)
  
  # --- Resultado ---
  result <- list(
    QBER = error_rate,
    Sifted_Length = sifted_length,
    Final_Key_Length = final_key_length,
    Eavesdropping = eavesdropping_active
  )
  
  class(result) <- c("BB84Simulation", "list")
  return(result)
}