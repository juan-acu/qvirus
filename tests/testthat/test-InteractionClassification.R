test_that("`InteractionClassifictaion()` works as expected", {
  set.seed(42)
  data(cd_3)
  cd_data <- cd_3[,-1]
  cd_result <- cds_diff(cd_data)
  data(vl_3)
  vl_data <- vl_3[,-1]
  vl_result <- vlogs_diff(vl_data)
  expect_snapshot(
      InteractionClassification(cd_result = cd_result, vl_result = vl_result)
  )
})
