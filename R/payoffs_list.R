#' Compute Payoff Values for Quantum HIV Phenotype Interactions
#'
#' Computes payoff values for all pairwise combinations of quantum gate strategies provided in
#' a named list. For each pair, the function calculates the payoffs for both phenotypes `v` and `V`
#' using two different sets of payoff parameters.
#'
#' @param gates A named list of 2x2 unitary matrices representing quantum strategies (e.g., I, H, Z).
#' @param alpha Numeric scalar, payoff coefficient for phenotype `v` when both play `0`.
#' @param beta Numeric scalar, payoff coefficient for phenotype `v` when `v` plays `0`, `V` plays `1`.
#' @param gamma Numeric scalar, payoff coefficient for phenotype `v` when `v` plays `1`, `V` plays `0`.
#' @param theta Numeric scalar, payoff coefficient for phenotype `v` and `V` when both play `1`.
#' @param alpha2 Numeric scalar, alternate value of \code{alpha} for phenotype `v` in a second scenario.
#' @param beta2 Numeric scalar, alternate value of \code{beta} for phenotype `v` in a second scenario.
#' @param gamma2 Numeric scalar, alternate value of \code{gamma} for phenotype `v` in a second scenario.
#' @param theta2 Numeric scalar, alternate value of \code{theta} for phenotype `v` in a second scenario.
#'
#' @export
#'
#' @examples
#' I <- diag(2)
#' H <- 1 / sqrt(2) * matrix(c(1, 1, 1, -1), 2, 2)
#' Z <- diag(c(1, -1))
#' gates <- list(I = I, H = H, Z = Z)
#' payoffs <- payoffs_list(gates, 1, 0.5, 0.3,0.2, 1.5, 0.6, 0.7, 0.8)
payoffs_list <- function(gates, alpha, beta, gamma, theta, alpha2, beta2, gamma2, theta2) {
  # Ensure the gates input is a named list for easy access
  if (!is.list(gates) || is.null(names(gates))) {
    stop("Gates must be a named list of matrices.")
  }
  
  # Initialize an empty list to store the payoffs
  pays_list <- list()
  
  # Iterate over the gates and generate names dynamically
  for (gate1_name in names(gates)) {
    for (gate2_name in names(gates)) {
      
      g1 <- gates[[gate1_name]]
      g2 <- gates[[gate2_name]]
      
      # Compute for first set of payoffs
      phen <- phen_hiv(g1, g2, alpha, beta, gamma, theta)
      pays_list[[paste0("v_", gate1_name, "_", gate2_name)]] <- phen$pi_v
      pays_list[[paste0("V_", gate1_name, "_", gate2_name)]] <- phen$pi_V
      
      # Compute for second set of payoffs
      phen_b <- phen_hiv(g1, g2, alpha2, beta2, gamma2, theta2)
      pays_list[[paste0("v_", gate1_name, "_", gate2_name, "_b")]] <- phen_b$pi_v
      pays_list[[paste0("V_", gate1_name, "_", gate2_name, "_b")]] <- phen_b$pi_V
    }
  }
  
  class(pays_list) <- c("QuantumPayoffs", "list")
  
  return(pays_list)
  
}