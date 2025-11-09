#' E91 Quantum Key Distribution (QKD) Simulation
#'
#' Simulates the E91 (Ekert 1991) quantum key distribution protocol using entangled
#' particle pairs (EPR) and Bell’s theorem (CHSH statistic) to ensure channel security.
#' Security is established when the \strong{Bell Inequality is violated}, i.e.
#' when \eqn{|S| > 2}, indicating quantum behavior.
#'
#' @param eavesdropping_active Logical. If \code{TRUE}, the entanglement is partially
#' destroyed, simulating an attack that forces the system toward the classical limit
#' where \eqn{|S| \leq 2}. Default is \code{FALSE}.
#' @param key_length Integer. Number of simulated EPR pairs (default = 1000).
#' @param noise_level Numeric. Noise level (0-1) applied when
#' \code{eavesdropping_active = TRUE}, reducing quantum correlation.
#' A value of 0.5 represents partial decoherence. Default is 0.5.
#'
#' @return A list of class \code{"E91Simulation"} containing:
#' \describe{
#'   \item{\code{S_Calculated}}{Observed Bell CHSH statistic.}
#'   \item{\code{S_Theoretical}}{Quantum theoretical value (\eqn{\approx} -2.8284).}
#'   \item{\code{Bell_Violation}}{\code{TRUE} if \eqn{|S| > 2} (secure),
#'   \code{FALSE} if \eqn{|S| \leq 2} (insecure).}
#'   \item{\code{Sifted_Key_Length}}{Number of bits retained for key formation.}
#'   \item{\code{Eavesdropping}}{Indicates if an attack was simulated.}
#' }
#'
#' @details
#' El E91 se diferencia de BB84 en que la detección del espía es \strong{simultánea} a la generación
#' de la clave. Los pares de bases son separados en dos conjuntos:
#' \enumerate{
#'  \item \strong{Clave Secreta:} Pares con perfecta anti-correlación (ej. a2-b1, a3-b2).
#'  \item \strong{Test de Bell:} Pares restantes usados para calcular la esperanza $E(a_i, b_j)$ y el valor $S$.
#' }
#' Si $S$ cae por debajo de 2 (límite clásico de Bell), se concluye que el entrelazamiento ha sido
#' roto por Eve, y la clave debe descartarse.
#'
#' @examples
#' # Escenario 1: Canal Cuántico Seguro (No Eavesdropping)
#' results_secure <- run_e91_simulation(eavesdropping_active = FALSE)
#' cat("--- Escenario 1: Sin Eavesdropping ---\n")
#' cat(paste("S Calculado:", round(results_secure$S_Calculated, 4), "\n"))
#' cat(paste("Violación de Bell:", results_secure$Bell_Violation, "\n"))
#'
#' # Escenario 2: Ataque que Rompe el Entrelazamiento
#' results_attack <- run_e91_simulation(eavesdropping_active = TRUE)
#' cat("\n--- Escenario 2: Con Ataque ---\n")
#' cat(paste("S Calculado:", round(results_attack$S_Calculated, 4), "\n"))
#' cat(paste("Violación de Bell:", results_attack$Bell_Violation, "\n"))
#'
#' @references
#' Ekert, A. K. (1991). \emph{Quantum cryptography based on Bell's theorem.}
#' Physical Review Letters, 67(6), 661.
#'
#' @export
run_e91_simulation <- function(eavesdropping_active = FALSE,
                               key_length = 1000,
                               noise_level = 0.5) {
  
  # --- 1. Definición de Parámetros y Bases ---
  ALICE_BASES_ANGLES <- c(0, pi/4, pi/2)
  names(ALICE_BASES_ANGLES) <- c("a1", "a2", "a3")
  BOB_BASES_ANGLES <- c(pi/4, pi/2, 3*pi/4)
  names(BOB_BASES_ANGLES) <- c("b1", "b2", "b3")
  
  S_QUANTUM_PREDICTION <- -2 * sqrt(2) 
  S_CLASSIC_LIMIT <- 2.0
  
  quantum_correlation_E <- function(theta_a, theta_b) {
    return(-cos(theta_a - theta_b))
  }
  
  simulate_entangled_measurement <- function(alice_angle, bob_angle, eavesdropping) {
    E_ideal <- quantum_correlation_E(alice_angle, bob_angle)
    
    # Simula ataque: reduce correlación hacia 0 (comportamiento clásico).
    E_actual <- if (eavesdropping) E_ideal * (1 - noise_level) else E_ideal
    
    P_same_sign <- (1 + E_actual) / 2 
    alice_result <- sample(c(1, -1), 1)
    
    bob_result <- if (stats::runif(1) < P_same_sign) alice_result else -alice_result 
    
    return(c(alice = alice_result, bob = bob_result))
  }
  
  # --- 2. Generación de Datos y Mediciones ---
  
  alice_base_indices <- sample(1:3, key_length, replace = TRUE)
  bob_base_indices <- sample(1:3, key_length, replace = TRUE)
  results_matrix <- matrix(NA, nrow = key_length, ncol = 2)
  key_bases <- matrix(NA, nrow = key_length, ncol = 2)
  
  for (i in 1:key_length) {
    a_idx <- alice_base_indices[i]
    b_idx <- bob_base_indices[i]
    theta_a <- ALICE_BASES_ANGLES[a_idx]
    theta_b <- BOB_BASES_ANGLES[b_idx]
    
    measurement <- simulate_entangled_measurement(theta_a, theta_b, eavesdropping_active)
    
    results_matrix[i, ] <- measurement
    key_bases[i, ] <- c(names(ALICE_BASES_ANGLES)[a_idx], names(BOB_BASES_ANGLES)[b_idx])
  }
  
  alice_results <- results_matrix[, 1]
  bob_results <- results_matrix[, 2]
  
  # --- 3. Tamizado (Sifting) para la Clave ---
  
  # Pares de bases que forman la clave (anti-correlación perfecta)
  key_indices <- which(
    (key_bases[, 1] == "a2" & key_bases[, 2] == "b1") | 
      (key_bases[, 1] == "a3" & key_bases[, 2] == "b2")    
  )
  
  raw_key_alice <- alice_results[key_indices]
  raw_key_bob_raw <- bob_results[key_indices]
  
  # Bob debe FLIPPEAR su resultado (-1 a +1) debido a la anti-correlación del estado singlet
  raw_key_bob_final <- -raw_key_bob_raw 
  key_length_sifted <- length(raw_key_alice)
  
  # --- 4. Test de Bell (Cálculo de S) ---
  
  calculate_E <- function(a_name, b_name, key_bases, alice_results, bob_results) {
    indices <- which(key_bases[, 1] == a_name & key_bases[, 2] == b_name)
    if (length(indices) < 2) return(NA)
    
    # E = Promedio del producto de los resultados (R_Alice * R_Bob)
    E_value <- mean(alice_results[indices] * bob_results[indices])
    return(E_value)
  }
  
  # Fórmula CHSH: S = E(a1, b1) - E(a1, b3) + E(a3, b1) + E(a3, b3)
  E_a1_b1 <- calculate_E("a1", "b1", key_bases, alice_results, bob_results)
  E_a1_b3 <- calculate_E("a1", "b3", key_bases, alice_results, bob_results)
  E_a3_b1 <- calculate_E("a3", "b1", key_bases, alice_results, bob_results)
  E_a3_b3 <- calculate_E("a3", "b3", key_bases, alice_results, bob_results)
  
  S_calculated <- E_a1_b1 - E_a1_b3 + E_a3_b1 + E_a3_b3
  
  # --- 5. Resultado ---
  
  bell_violation <- abs(S_calculated) > S_CLASSIC_LIMIT
  
  result <- list(
    S_Calculated = S_calculated,
    S_Theoretical = S_QUANTUM_PREDICTION,
    S_Classic_Limit = S_CLASSIC_LIMIT,
    Bell_Violation = bell_violation,
    Sifted_Key_Length = key_length_sifted,
    Eavesdropping = eavesdropping_active
  )
  
  class(result) <- c("E91Simulation", "list")
  
  return(result)
}