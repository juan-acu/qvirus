test_that("`cds_diff()` works as expected", {
  data(cd_3)
  cd_data <- cd_3[,-1]
  expect_snapshot(
      cds_diff(cd_data) 
  )
})