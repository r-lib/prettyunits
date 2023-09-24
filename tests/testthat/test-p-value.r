context("p-values")

test_that("p-values work", {
  expect_equal(
    pretty_p_value(c(1, 0, NA, 0.01, 0.0000001)),
    c("1.0000", "<0.0001", NA_character_, "0.0100", "<0.0001")
  )
  expect_equal(
    pretty_p_value(c(1, 0, NA, 0.01, 0.0000001), minval=0.05),
    c("1.00", "<0.05", NA_character_, "<0.05", "<0.05")
  )
  expect_equal(pretty_p_value(NA_real_), NA_character_)
  expect_error(pretty_p_value(1, minval="A"))
  expect_error(pretty_p_value("A"))
  expect_error(pretty_p_value(1.1))
  expect_error(pretty_p_value(-1))
  expect_error(pretty_p_value(0.5, minval=0))
  expect_error(pretty_p_value(0.5, minval=1))
})
