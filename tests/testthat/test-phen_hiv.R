test_that("phen_hiv() works as expected", {
  strategy1 <- diag(2) 
  strategy2 <- diag(2) 
  alpha <- 1
  beta <- 0.5
  gamma <- 2
  theta <- 0.1 
  expect_snapshot(
    phen_hiv(strategy1, strategy2, alpha, beta, gamma, theta) 
  )
})
