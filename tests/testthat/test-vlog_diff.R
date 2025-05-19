test_that("`vlog_diff()` works as expected", {
  data(vl_3)
  vl_data <- vl_3[,-1]
  expect_snapshot(
      vlog_diff(vl_data) 
  )
})
