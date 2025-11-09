test_that("run_bb84_simulation() returns expected structure", {
  set.seed(42)
  result <- run_bb84_simulation(eavesdropping_active = FALSE, key_length = 500, test_ratio = 0.2)
  
  # Class and type checks
  testthat::expect_s3_class(result, "BB84Simulation")
  testthat::expect_type(result$QBER, "double")
  testthat::expect_type(result$Sifted_Length, "integer")
  testthat::expect_type(result$Final_Key_Length, "integer")
  testthat::expect_type(result$Eavesdropping, "logical")
  
  # Logical consistency checks
  testthat::expect_true(result$Sifted_Length <= 500)
  testthat::expect_true(result$Final_Key_Length <= result$Sifted_Length)
  testthat::expect_true(result$QBER >= 0)
  testthat::expect_true(result$QBER <= 1)
# })