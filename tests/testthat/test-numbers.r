
context("Pretty numbers")

test_that("sizes.R is standalone", {
  stenv <- environment(format_num$pretty_num)
  objs <- ls(stenv, all.names = TRUE)
  funs <- Filter(function(x) is.function(stenv[[x]]), objs)
  funobjs <- mget(funs, stenv)
  for (f in funobjs) expect_identical(environmentName(topenv(f)), "base")

  expect_message(
    mapply(codetools::checkUsage, funobjs, funs,
           MoreArgs = list(report = message)),
    NA)
})

test_that("pretty_num gives errors on invalid input", {

  expect_error(pretty_num(''), 'is.numeric.*is not TRUE')
  expect_error(pretty_num('1'), 'is.numeric.*is not TRUE')
  expect_error(pretty_num(TRUE), 'is.numeric.*is not TRUE')
  expect_error(pretty_num(list(1,2,3)), 'is.numeric.*is not TRUE')

})

test_that("pretty_num converts properly", {

  expect_equal(pretty_num(1e-24), '1 y')
  expect_equal(pretty_num(-1e-4), '-100.00 u')
  expect_equal(pretty_num(-0.01), '-10 m')
  expect_equal(pretty_num(0), '0 ')
  expect_equal(pretty_num(10), '10 ')
  expect_equal(pretty_num(999), '999 ')
  expect_equal(pretty_num(1001), '1.00 k')
  expect_equal(pretty_num(1000 * 1000 - 1), '1.00 M')
  expect_equal(pretty_num(1e16), '10 P')
  expect_equal(pretty_num(1e30), '1000000 Y')

})

test_that("pretty_num handles NA and NaN", {

  expect_equal(pretty_num(NA_real_), "NA ")
  expect_equal(pretty_num(NA_integer_), "NA ")
  expect_error(pretty_num(NA_character_), 'is.numeric.*is not TRUE')
  expect_error(pretty_num(NA), 'is.numeric.*is not TRUE')

  expect_equal(pretty_num(NaN), "NaN ")

})

test_that("pretty_num handles vectors", {

  expect_equal(pretty_num(1:10), paste(format(1:10), ""))

  v <- c(NA, -1e-7, 1, 1e4, 1e6, NaN, 1e5)
  expect_equal(pretty_num(v),
    c("      NA ", "-100.00 n","       1 ", "     10 k", "      1 M", "     NaN ", "    100 k"))

  expect_equal(pretty_num(numeric()), character())
})

test_that("pretty_num nopad style", {

  v <- c(NA, 1, 1e4, 1e6, NaN, 1e5)
  expect_equal(pretty_num(v, style = "nopad"),
    c("NA ", "1 ", "10 k", "1 M", "NaN ", "100 k"))
  expect_equal(pretty_num(numeric(), style = "nopad"), character())
})

test_that("pretty_num handles negative values", {
  v <- c(NA, -1, 1e4, 1e6, NaN, -1e5)
  expect_equal(pretty_num(v),
    c("   NA ", "   -1 ", "  10 k", "   1 M", "  NaN ", "-100 k"))

})

test_that("always two fraction digits", {
  expect_equal(
    pretty_num(c(5.6, 5, NA) * 1000 * 1000),
    c("5.60 M", "   5 M", "   NA ")
  )
})

test_that("6 width style", {
  cases <- c(
    " -10 k" = -1e4,                    # 1
    "-111  " = -111.33333,              # 2
    "-100  " = -100,                    # 3
    " -10  " = -10.33333,               # 4
    " -10  " = -9.99999,                # 5
    "-9.0  " = -9,                      # 6
    "-1.0  " = -1,                      # 7
    "0.00  " = 0,                       # 8
    "1.00  " = 1,                       # 9
    "9.00  " = 9,                       # 10
    "10.0  " = 9.99999,                 # 11
    "10.3  " = 10.33333,                # 12
    " 100  " = 100,                     # 13
    " 111  " = 111.33333,               # 14
    "1.00 k" = 1e3,                     # 15
    "1.05 k" = 1049,                    # 16
    "1.05 k" = 1051,                    # 17
    "1.10 k" = 1100,                    # 18
    "10.0 k" = 1e4,                     # 19
    " 100 k" = 1e5,                     # 20
    "1.00 M" = 1e6,                     # 21
    " NaN  " = NaN,                     # 22
    "  NA  " = NA                       # 23
  )
  
  expect_equal(pretty_num(unname(cases), style = "6"), names(cases))
})

test_that("No fractional bytes (#23)", {
  cases <- c(
    "    -1 " = -1,                   # 1
    "     1 " = 1,                    # 2
    "    16 " = 16,                   # 3
    "   128 " = 128,                  # 4
    " 1.02 k" = 1024,                 # 5
    "16.38 k" = 16384,                # 6
    " 1.05 M" = 1048576,              # 7
    "-1.05 M" = -1048576,             # 8
    "    NA " = NA                    # 9
  )

  expect_equal(pretty_num(unname(cases)), names(cases))
})

test_that("compute_num handles `smallest_prefix` properly", {
  
  expect_equal(compute_num(1e-24, smallest_prefix = "m"), data.frame(amount = 1e-21, prefix = "m", negative = FALSE, stringsAsFactors = FALSE))
  expect_equal(compute_num(-1e-4, smallest_prefix = "m"), data.frame(amount = 0.1, prefix = "m", negative = TRUE, stringsAsFactors = FALSE))
  expect_equal(compute_num(-0.01, smallest_prefix = "m"), data.frame(amount = 10, prefix = "m", negative = TRUE, stringsAsFactors = FALSE))
  expect_equal(compute_num(0, smallest_prefix = "m"), data.frame(amount = 0, prefix = "", negative = FALSE, stringsAsFactors = FALSE))
})
