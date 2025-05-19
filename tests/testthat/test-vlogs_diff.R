test_that("`vlogs_diff()` works as expected", {
  data(vl_3)
  vl_data <- vl_3[,-1]
  expect_snapshot(
    vlogs_diff(vl_data) 
  )
})