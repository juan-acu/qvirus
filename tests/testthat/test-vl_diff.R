test_that("`vl_diff()` works as expected", {
  data(vl_3)
  vl_data <- vl_3[,-1]
  expect_snapshot(
    print(
      vl_diff(vl_data) 
    )
  )
})