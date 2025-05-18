test_that("`cd_diff()` works as expected", {
  data(cd_3)
  cd_data <- cd_3[,-1]
  expect_snapshot(
      cd_diff(cd_data) 
  )
})
