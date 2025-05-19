#' Calculate Final State and Payoffs in Quantum Game
#'
#' This function calculates the final quantum state and expected payoffs for two 
#' players in a quantum game based on their strategies. The function uses quantum 
#' gates and unitary transformations to simulate the game dynamics.
#'
#' @param strategy1 A 2x2 matrix representing the strategy of player 1.
#' @param strategy2 A 2x2 matrix representing the strategy of player 2.
#' @param alpha A numeric value representing the payoff for outcome |00>.
#' @param beta A numeric value representing the payoff for outcome |01>.
#' @param gamma A numeric value representing the payoff for outcome |10>.
#' @param theta A numeric value representing the payoff for outcome |11>. 
#'
#' @export
#'
#' @examples
#' strategy1 <- diag(2) # Identity matrix for strategy 1
#' strategy2 <- diag(2) # Identity matrix for strategy 2
#' alpha <- 1
#' beta <- 0.5
#' gamma <- 2
#' theta <- 0.1
#' result <- phen_hiv(strategy1, strategy2, alpha, beta, gamma, theta)
#' 
#' @references
#' Özlüer Başer, B. (2022). "Analyzing the competition of HIV-1 phenotypes with quantum game theory". 
#' Gazi University Journal of Science, 35(3), 1190--1198. \doi{10.35378/gujs.772616}
phen_hiv <- function(strategy1, strategy2, alpha, beta, gamma, theta){
  # Define the quantum gates
  I <- diag(2)
  X <- matrix(c(0, 1, 1, 0), nrow=2)
  
  # Define the initial state |00>
  initial_state <- array(complex(real = c(1,0,0,0), imaginary = c(0,0,0,0)), dim = c(4, 1))
  
  # Define the unitary transformation for mutant H gate
  U <- 1/sqrt(2) * (kronecker(I, I) - 1i * kronecker(X, X))
  V <- 1/sqrt(2) * (kronecker(I, I) + 1i * kronecker(X, X))
  
  # Apply the sequence of operations to the initial state
  state_after_U <- U %*% initial_state
  state_after_strategy <- kronecker(strategy1, strategy2) %*% state_after_U
  state_after_V <- V %*% state_after_strategy
  final_state <- U %*% state_after_V
  
  # Apply the inverse unitary transformation
  U_inverse <- Conj(t(U))
  psi_f <- U_inverse %*% final_state
  
  # Calculate the probabilities for each basis state
  prob_00 <- Mod(psi_f[1])^2
  prob_01 <- Mod(psi_f[2])^2
  prob_10 <- Mod(psi_f[3])^2
  prob_11 <- Mod(psi_f[4])^2
  
  # Calculate the expected payoffs for players v and V
  pi_v <- alpha * prob_00 + beta * prob_01 + gamma * prob_10 + theta * prob_11
  pi_V <- alpha * prob_00 + gamma * prob_01 + beta * prob_10 + theta * prob_11
  
  phen <- data.frame(prob_00 = prob_00, prob_01 = prob_01, prob_10 = prob_10, prob_11 = prob_11,
             pi_v = pi_v, pi_V = pi_V)
  
  class(phen) <- c("qgame", "data.frame")
  
  return(phen)  
  
}