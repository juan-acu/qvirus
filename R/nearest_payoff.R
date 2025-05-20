#' Find Nearest Payoff
#'
#' This function computes the nearest simulated payoff from a given list of payoffs 
#' based on a viral load difference (vl_diff). It returns both the nearest payoff value 
#' and its corresponding payoff name.
#'
#' @param vl_diff Numeric value representing the viral load difference for which the 
#' nearest payoff will be found.
#' @param payoffs_list A named list of payoff values, where the names correspond to 
#' specific payoffs and the values are the associated payoff values. 
#'
#' @export
#'
#' @examples
#'  I <- diag(2)
#'  H <- 1 / sqrt(2) * matrix(c(1, 1, 1, -1), 2, 2)
#'  Z <- diag(c(1, -1))
#'  gates <- list(I = I, H = H, Z = Z)
#'  alpha <- 0.3; beta <- 0.1; gamma <- 0.5; theta <- 0.2
#'  alpha2 <- 0.35; beta2 <- 0.15; gamma2 <- 0.6; theta2 <- 0.25
#'  pays <- payoffs_list(gates, alpha, beta, gamma, theta, alpha2, beta2, gamma2, theta2)
#'  nearest_payoff(-0.2, pays)
nearest_payoff <- function(vl_diff, payoffs_list){
  stopifnot(is.numeric(vl_diff), length(vl_diff) == 1)
  stopifnot(is.list(payoffs_list), !is.null(names(payoffs_list)))
  payoff_values <- unlist(payoffs_list)
  payoff_names <- names(payoffs_list)
  differences <- abs(vl_diff - payoff_values)
  min_index <- which.min(differences)
  pays_list = list(value = payoff_values[min_index], name = payoff_names[min_index])
  class(pays_list) <- c("NearestPayoff", "list")
  return(pays_list)
}