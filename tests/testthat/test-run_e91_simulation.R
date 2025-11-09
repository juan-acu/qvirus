test_that("run_e91_simulation() returns expected structure", {
  set.seed(42)
  # Usaremos un key_length bajo para que las pruebas de valores específicos sean más estables
  result <- run_e91_simulation(eavesdropping_active = FALSE, key_length = 2000, noise_level = 0)
  
  # --- 1. Class and Type Checks ---
  testthat::expect_s3_class(result, "E91Simulation")
  testthat::expect_type(result$S_Calculated, "double")
  testthat::expect_type(result$S_Theoretical, "double")
  testthat::expect_type(result$S_Classic_Limit, "double")
  testthat::expect_type(result$Bell_Violation, "logical")
  testthat::expect_type(result$Sifted_Key_Length, "integer")
  testthat::expect_type(result$Eavesdropping, "logical")
})
