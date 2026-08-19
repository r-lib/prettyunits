test_that("Rounding", {
  expect_error(
    pretty_round(1, c(2, 3)),
    "digits must either be a scalar or the same length as x",
    fixed = TRUE
  )
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
  expect_equal(
    pretty_round(c(100, 0.1), 3),
    c("100.000", "0.100"),
    info = "Vectors work with different orders of magnitude work"
  )
  expect_equal(
    pretty_round(c(100, 0.1), c(0, 3)),
    c("100", "0.100"),
    info = "Vectors of digits work"
  )
  expect_equal(
    pretty_round(c(0.1, NA), digits = 3),
    c("0.100", "NA"),
    info = "Mixed inputs (NA, NaN, Inf or numeric), NA"
  )
  expect_equal(
    pretty_round(c(0.1, NA, NaN, Inf, -Inf), digits = 3),
    c("0.100", "NA", "NaN", "Inf", "-Inf"),
    info = "Mixed inputs (NA, NaN, Inf or numeric)"
  )
  ## All zeros
  expect_equal(pretty_round(0, digits = 3), "0.000")
  expect_equal(pretty_round(c(0, NA), digits = 3), c("0.000", "NA"))
  # scientific notation
  expect_equal(
    pretty_round(1234567, digits = 3, sci_range = 5),
    "1.234567000e6",
    info = "sci_range works with pretty_round (even if it looks odd)"
  )
  expect_equal(
    pretty_round(1234567, digits = 3, sci_range = 5),
    pretty_round(1234567, digits = 3, sci_range = 5),
    info = "sci_range works with pretty_round (even if it looks odd)"
  )
  expect_equal(
    pretty_round(1234567, digits = 3, sci_range = 5, sci_sep = "x10^"),
    "1.234567000x10^6",
    info = "sci_sep is respected."
  )
  expect_equal(
    pretty_round(c(1e7, 1e10), digits = c(-3, -9), sci_range = 5),
    c("1.0000e7", "1.0e10"),
    info = "Different numbers of digits for rounding work with pretty_round"
  )
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
  expect_equal(pretty_signif(123456.05, 3, sci_range = 6), "123000")
  expect_equal(pretty_signif(123456.05, 3, sci_range = 5), "1.23e5")
  expect_equal(pretty_signif(-123000.05, 3, sci_range = 5), "-1.23e5")
  expect_equal(
    pretty_signif(999999, 3, sci_range = 6),
    "1.00e6",
    info = "Rounding around the edge of the sci_range works correctly (going up)"
  )
  expect_equal(
    pretty_signif(999999, 7, sci_range = 6),
    "999999.0",
    info = "Rounding around the edge of the sci_range works correctly (going staying the same)"
  )
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
  expect_equal(pretty_signif(c(0.1, NA), digits = 3), c("0.100", "NA"))
  expect_equal(
    pretty_signif(c(0.1, NA, NaN, Inf, -Inf), digits = 3),
    c("0.100", "NA", "NaN", "Inf", "-Inf")
  )
  ## All zeros
  expect_equal(pretty_signif(0, digits = 3), "0.000")
  expect_equal(pretty_signif(c(0, NA), digits = 3), c("0.000", "NA"))

  expect_equal(
    pretty_signif(1234567, digits = 3, sci_range = 5, sci_sep = "x10^"),
    "1.23x10^6",
    info = "sci_sep is respected."
  )
  expect_equal(
    pretty_signif(c(1e7, 1e10), digits = 3),
    c("1.00e7", "1.00e10"),
    info = "Different numbers of digits for rounding work with pretty_signif"
  )
})

test_that("Zero-length input returns a zero-length character vector", {
  expect_identical(pretty_round(numeric(0), 2), character(0))
  expect_identical(pretty_round(numeric(0), numeric(0)), character(0))
  expect_identical(pretty_round(NULL, 2), character(0))
  expect_identical(pretty_signif(numeric(0), 3), character(0))
  expect_identical(pretty_signif(NULL, 3), character(0))
  expect_error(
    pretty_round(numeric(0), c(1, 2)),
    "digits must either be a scalar or the same length as x",
    fixed = TRUE
  )
})

test_that("Argument checking", {
  expect_error(
    pretty_round(1.234, NA),
    "digits must be finite and numeric",
    fixed = TRUE
  )
  expect_error(
    pretty_round(1.234, Inf),
    "digits must be finite and numeric",
    fixed = TRUE
  )
  expect_error(
    pretty_signif(1.234, NaN),
    "digits must be finite and numeric",
    fixed = TRUE
  )
  expect_error(
    pretty_signif(1.234, "3"),
    "digits must be finite and numeric",
    fixed = TRUE
  )
  expect_error(
    pretty_round(1.234, 2, sci_range = NA),
    "sci_range must be a scalar, non-missing number",
    fixed = TRUE
  )
  expect_error(
    pretty_signif(1.234, 2, sci_range = c(1, 2)),
    "sci_range must be a scalar, non-missing number",
    fixed = TRUE
  )
  expect_error(
    pretty_round(1.234, 2, sci_sep = NA),
    "sci_sep must be a scalar, non-missing character string",
    fixed = TRUE
  )
  expect_error(
    pretty_signif(1.234, 2, sci_sep = c("e", "x10^")),
    "sci_sep must be a scalar, non-missing character string",
    fixed = TRUE
  )
  ## sci_range = Inf remains valid
  expect_equal(pretty_signif(1e7, 3, sci_range = Inf), "10000000")
})

test_that("Non-integer digits are rounded to the nearest integer", {
  expect_equal(pretty_round(1.234, 2.7), "1.234")
  expect_equal(pretty_round(1.234, 2.2), "1.23")
  expect_equal(pretty_signif(1.234, 2.7), "1.23")
  expect_equal(pretty_signif(1.234, 2.2), "1.2")
})

test_that("pretty_signif() checks the length of digits", {
  expect_error(
    pretty_signif(1.234, c(2, 3)),
    "digits must either be a scalar or the same length as x",
    fixed = TRUE
  )
  expect_error(
    pretty_signif(c(1.1, 2.2, 3.3), c(1, 2)),
    "digits must either be a scalar or the same length as x",
    fixed = TRUE
  )
  ## Each element gets its own number of significant digits
  expect_equal(
    pretty_signif(c(1.1, 2.2, 3.3), c(1, 2, 3)),
    c("1", "2.2", "3.30")
  )
  ## Zero takes its digits from the matching element, not the first
  expect_equal(pretty_signif(c(0, 1.234), c(2, 3)), c("0.00", "1.23"))
  ## The magnitude bump is applied per element
  expect_equal(pretty_signif(c(0.9999, 1e7), c(2, 3)), c("1.0", "1.00e7"))
})

test_that("pretty_signif() treats digits smaller than 1 as 1", {
  expect_warning(
    expect_equal(pretty_signif(123.456, 0), "100"),
    "digits values smaller than 1 are treated as 1",
    fixed = TRUE
  )
  expect_warning(
    expect_equal(pretty_signif(123.456, -1), "100"),
    "digits values smaller than 1 are treated as 1",
    fixed = TRUE
  )
  expect_warning(
    expect_equal(pretty_signif(0.00123, 0), "0.001"),
    "digits values smaller than 1 are treated as 1",
    fixed = TRUE
  )
  ## Clamping is per element
  expect_warning(
    expect_equal(pretty_signif(c(123.456, 1.234), c(0, 3)), c("100", "1.23")),
    "digits values smaller than 1 are treated as 1",
    fixed = TRUE
  )
  ## pretty_round() still accepts negative digits
  expect_equal(pretty_round(123.456, -2), "100")
})

test_that("names and dim of x are preserved", {
  expect_equal(
    pretty_round(c(a = 1.2, b = 5.6), 2),
    c(a = "1.20", b = "5.60"),
    info = "Scalar digits keeps names"
  )
  expect_equal(
    pretty_round(c(a = 1.2, b = 5.6), c(1, 2)),
    c(a = "1.2", b = "5.60"),
    info = "Vector digits keeps names"
  )
  expect_equal(
    pretty_signif(c(a = 1.2, b = 5.6), 2),
    c(a = "1.2", b = "5.6")
  )
  m <- matrix(1:6 / 7, nrow = 2, dimnames = list(c("r1", "r2"), NULL))
  expect_equal(dim(pretty_round(m, 2)), c(2L, 3L))
  expect_equal(dimnames(pretty_round(m, 2)), list(c("r1", "r2"), NULL))
  expect_equal(dim(pretty_round(m, rep(2, 6))), c(2L, 3L))
  expect_equal(dim(pretty_signif(m, 2)), c(2L, 3L))
})

test_that("Scientific notation handles more than one value at a time", {
  expect_equal(
    pretty_round(c(1e7, 2e7), 3, sci_range = 5),
    c("1.0000000000e7", "2.0000000000e7")
  )
  expect_equal(
    pretty_round(c(1e7, 1e10), 3, sci_range = 5),
    c("1.0000000000e7", "1.0000000000000e10"),
    info = "Each element gets the decimals implied by its own magnitude"
  )
  expect_equal(
    pretty_signif(c(1e7, 1e10), 3, sci_range = 5),
    c("1.00e7", "1.00e10")
  )
})

test_that("The scientific notation mantissa is normalized", {
  ## Dividing by 10^logval underflows for denormals and left a mantissa >= 10
  expect_equal(pretty_signif(1e-320, 3, sci_range = 0), "1.00e-320")
  expect_equal(pretty_signif(1e-319, 3, sci_range = 0), "1.00e-319")
  expect_equal(pretty_signif(-1e-320, 3, sci_range = 0), "-1.00e-320")
  ## The smallest denormal gave a mantissa of Inf
  expect_equal(pretty_signif(5e-324, 3, sci_range = 0), "5.00e-324")
  ## 1 <= abs(mantissa) < 10 across the whole range of a double
  mantissa <- as.numeric(sub(
    "e.*$", "",
    pretty_signif(10^(-323:308), 3, sci_range = 0)
  ))
  expect_true(all(abs(mantissa) >= 1 & abs(mantissa) < 10))
})

test_that("Digits past the ones a double carries are zeros", {
  ## formatC() printed the exact decimal expansion of the double instead
  expect_equal(
    pretty_signif(1.234, 30),
    paste0("1.234", strrep("0", 26))
  )
  expect_equal(
    pretty_round(1.234, 30, sci_range = 0),
    paste0("1.234", strrep("0", 27), "e0")
  )
  expect_equal(
    pretty_round(1e300, 3, sci_range = Inf),
    paste0("1", strrep("0", 300), ".000")
  )
  ## formatC() warned "digits reduced to 324" and truncated
  expect_equal(nchar(pretty_signif(1.234, 400)), 401L)
  expect_silent(pretty_signif(1.234, 400))
  ## Digits the double does carry are kept
  expect_equal(pretty_signif(pi, 16), "3.141592653589793")
  expect_equal(pretty_signif(pi, 17), "3.1415926535897931")
  expect_equal(
    pretty_signif(pi, 25),
    paste0("3.141592653589793", strrep("0", 9))
  )
})

test_that("sci_range is inclusive at the boundary", {
  ## An exact power of ten at abs(log10(x)) == sci_range is scientific
  expect_equal(pretty_signif(1e6, 6), "1.00000e6")
  expect_equal(pretty_signif(1e6, 3, sci_range = 6), "1.00e6")
  expect_equal(pretty_signif(1e-6, 3, sci_range = 6), "1.00e-6")
  expect_equal(pretty_round(1e6, 2, sci_range = 6), "1.00000000e6")
  ## Just inside the boundary stays fixed
  expect_equal(pretty_signif(123456.05, 3, sci_range = 6), "123000")
  expect_equal(pretty_round(999999, 2, sci_range = 6), "999999.00")
})

test_that("Rounding is round-half-even", {
  expect_equal(pretty_round(c(0.5, 1.5, 2.5, 3.5), 0), c("0", "2", "2", "4"))
  expect_equal(pretty_signif(c(0.5, 1.5, 2.5, 3.5), 1), c("0.5", "2", "2", "4"))
  ## 2.675 is below 2.675 as a double, so it rounds down
  expect_equal(pretty_round(2.675, 2), "2.67")
})

test_that("A negative value that rounds to zero keeps its sign", {
  expect_equal(
    pretty_round(c(-0.4, -0.0001, -1e-20), 2),
    c("-0.40", "-0.00", "-0.00")
  )
  expect_equal(pretty_round(-0.4, 0), "-0")
  expect_equal(
    pretty_signif(-1e-20, 2, sci_range = Inf),
    "-0.000000000000000000010"
  )
})
