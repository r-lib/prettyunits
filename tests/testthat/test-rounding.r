context("Rounding to string values")

test_that("Rounding", {
  expect_error(pretty_round(1, c(2, 3)),
               regexp="digits must either be a scalar or the same length as x")
  expect_equal(pretty_round(11), "11")
  expect_equal(pretty_round(5), "5")
  expect_equal(pretty_round(0.05), "0")
  expect_equal(pretty_round(NA), "NA")
  expect_equal(pretty_round(NaN), "NaN")
  expect_equal(pretty_round(Inf), "Inf")
  expect_equal(pretty_round(-Inf), "-Inf")
  ## Respecting the digits
  expect_equal(pretty_round(0.05, 3), "0.050")
  expect_equal(pretty_round(123.05, 3), "123.050")
  expect_equal(pretty_round(c(100, 0.1), 3), c("100.000", "0.100"),
               info="Vectors work with different orders of magnitude work")
  expect_equal(pretty_round(c(100, 0.1), c(0, 3)), c("100", "0.100"),
               info="Vectors of digits work")
  expect_equal(pretty_round(c(0.1, NA), digits=3), c("0.100", "NA"),
               info="Mixed inputs (NA, NaN, Inf or numeric), NA")
  expect_equal(pretty_round(c(0.1, NA, NaN, Inf, -Inf), digits=3),
               c("0.100", "NA", "NaN", "Inf", "-Inf"),
               info="Mixed inputs (NA, NaN, Inf or numeric)")
  ## All zeros
  expect_equal(pretty_round(0, digits=3), "0.000")
  expect_equal(pretty_round(c(0, NA), digits=3), c("0.000", "NA"))
  # scientific notation
  expect_equal(pretty_round(1234567, digits=3, sci_range=5), "1.234567000e6",
               info="sci_range works with pretty_round (even if it looks odd)")
  expect_equal(pretty_round(1234567, digits=3, sci_range=5),
               pretty_round(1234567, digits=3, sci_range=5),
               info="sci_range works with pretty_round (even if it looks odd)")
  expect_equal(pretty_round(1234567, digits=3, sci_range=5, sci_sep="x10^"),
               "1.234567000x10^6",
               info="sci_sep is respected.")
  expect_equal(pretty_round(c(1e7, 1e10), digits=c(-3, -9), sci_range=5),
               c("1.0000e7", "1.0e10"),
               info="Different numbers of digits for rounding work with pretty_round")
})

test_that("Significance", {
  expect_equal(pretty_signif(11), "11.0000")
  expect_equal(pretty_signif(5), "5.00000")
  expect_equal(pretty_signif(0.05), "0.0500000")
  expect_equal(pretty_signif(NA), "NA")
  expect_equal(pretty_signif(NaN), "NaN")
  expect_equal(pretty_signif(Inf), "Inf")
  expect_equal(pretty_signif(-Inf), "-Inf")
  ## Respecting the digits
  expect_equal(pretty_signif(0.05, 3), "0.0500")
  expect_equal(pretty_signif(123.05, 3), "123")
  expect_equal(pretty_signif(123456.05, 3), "123000")
  expect_equal(pretty_signif(123456.05, 3, sci_range=6), "123000")
  expect_equal(pretty_signif(123456.05, 3, sci_range=5), "1.23e5")
  expect_equal(pretty_signif(-123000.05, 3, sci_range=5), "-1.23e5")
  expect_equal(pretty_signif(999999, 3, sci_range=6), "1.00e6",
               info="Rounding around the edge of the sci_range works correctly (going up)")
  expect_equal(pretty_signif(999999, 7, sci_range=6), "999999.0",
               info="Rounding around the edge of the sci_range works correctly (going staying the same)")
  expect_equal(pretty_signif(-.05, 3), "-0.0500")
  ## Exact orders of magnitude work on both sides of 0
  expect_equal(pretty_signif(0.01, 3), "0.0100")
  expect_equal(pretty_signif(1, 3), "1.00")
  expect_equal(pretty_signif(100, 3), "100")
  ## Vectors work with different orders of magnitude work
  expect_equal(pretty_signif(c(100, 0.1), 3), c("100", "0.100"))
  ## Rounding to a higher number of significant digits works correctly
  expect_equal(pretty_signif(0.9999999, 3), "1.00")
  ## Mixed inputs (NA, NaN, Inf or numeric)
  expect_equal(pretty_signif(NA), "NA")
  expect_equal(pretty_signif(c(0.1, NA), digits=3), c("0.100", "NA"))
  expect_equal(pretty_signif(c(0.1, NA, NaN, Inf, -Inf), digits=3),
               c("0.100", "NA", "NaN", "Inf", "-Inf"))
  ## All zeros
  expect_equal(pretty_signif(0, digits=3), "0.000")
  expect_equal(pretty_signif(c(0, NA), digits=3), c("0.000", "NA"))
  
  expect_equal(pretty_signif(1234567, digits=3, sci_range=5, sci_sep="x10^"),
               "1.23x10^6",
               info="sci_sep is respected.")
  expect_equal(pretty_signif(c(1e7, 1e10), digits=3),
               c("1.00e7", "1.00e10"),
               info="Different numbers of digits for rounding work with pretty_signif")
})
