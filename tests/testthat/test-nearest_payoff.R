test_that("`nearest_payoff()` works as expected", {
  I <- diag(2)
  H <- 1 / sqrt(2) * matrix(c(1, 1, 1, -1), 2, 2)
  Z <- diag(c(1, -1))
  gates <- list(I = I, H = H, Z = Z)
  alpha <- 0.3; beta <- 0.1; gamma <- 0.5; theta <- 0.2
  alpha2 <- 0.35; beta2 <- 0.15; gamma2 <- 0.6; theta2 <- 0.25
  pays <- payoffs_list(gates, alpha, beta, gamma, theta, alpha2, beta2, gamma2, theta2)
  expect_snapshot(nearest_payoff(-0.2, pays))
})