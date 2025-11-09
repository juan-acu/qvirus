#' E91 Quantum Key Distribution (QKD) Simulation
#'
#' Simula el protocolo E91 (Ekert 1991), el cual utiliza pares de partículas entrelazadas (EPR)
#' y el Teorema de Bell (Estadística CHSH) para garantizar la seguridad de la clave.
#' La seguridad se establece al verificar la \strong{Violación de la Desigualdad de Bell},
#' donde un valor $|S| > 2$ indica que el canal es seguro (comportamiento cuántico).
#'
#' @param eavesdropping_active Logical. Si \code{TRUE}, el entrelazamiento es
#' parcialmente destruido, simulando un ataque que fuerza el comportamiento del
#' sistema hacia el límite clásico, donde $|S| \le 2$. Default es \code{FALSE}.
#' @param key_length Integer. Número de pares EPR simulados. El default es 1000.
#' @param noise_level Numeric. Nivel de ruido simulado (entre 0 y 1) si
#' 'eavesdropping_active' es TRUE, afectando la correlación cuántica.
#' Un valor de 0.5 rompe parcialmente el entrelazamiento. Default es 0.5.
#'
#' @return
#' Una lista de clase \code{"E91Simulation"} conteniendo:
#' \describe{
#'  \item{\code{S_Calculated}}{Valor observado de la Estadística de Bell (S_CHSH).}
#'  \item{\code{S_Theoretical}}{Valor cuántico teórico esperado (aproximadamente -2.8284).}
#'  \item{\code{Bell_Violation}}{Logical. \code{TRUE} si $|S| > 2$ (seguro), \code{FALSE} si $|S| \le 2$ (inseguro).}
#'  \item{\code{Sifted_Key_Length}}{Número de bits retenidos para formar la clave después del tamizado (correlación perfecta).}
#'  \item{\code{Eavesdropping}}{Flag que indica si el ataque fue simulado.}
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
    
    bob_result <- if (runif(1) < P_same_sign) alice_result else -alice_result 
    
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