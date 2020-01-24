
context("Pretty bytes")

test_that("sizes.R is standalone", {
  stenv <- environment(format_bytes$pretty_bytes)
  objs <- ls(stenv, all.names = TRUE)
  funs <- Filter(function(x) is.function(stenv[[x]]), objs)
  funobjs <- mget(funs, stenv)
  for (f in funobjs) expect_identical(environmentName(topenv(f)), "base")

  expect_message(
    mapply(codetools::checkUsage, funobjs, funs,
           MoreArgs = list(report = message)),
    NA)
})

test_that("pretty_bytes gives errors on invalid input", {

  expect_error(pretty_bytes(''), 'is.numeric.*is not TRUE')
  expect_error(pretty_bytes('1'), 'is.numeric.*is not TRUE')
  expect_error(pretty_bytes(TRUE), 'is.numeric.*is not TRUE')
  expect_error(pretty_bytes(list(1,2,3)), 'is.numeric.*is not TRUE')

})

test_that("pretty_bytes converts properly", {

  expect_equal(pretty_bytes(0), '0 B')
  expect_equal(pretty_bytes(10), '10 B')
  expect_equal(pretty_bytes(999), '999 B')
  expect_equal(pretty_bytes(1001), '1.00 kB')
  expect_equal(pretty_bytes(1000 * 1000 - 1), '1.00 MB')
  expect_equal(pretty_bytes(1e16), '10 PB')
  expect_equal(pretty_bytes(1e30), '1000000 YB')

})

test_that("pretty_bytes handles NA and NaN", {

  expect_equal(pretty_bytes(NA_real_), "NA B")
  expect_equal(pretty_bytes(NA_integer_), "NA B")
  expect_error(pretty_bytes(NA_character_), 'is.numeric.*is not TRUE')
  expect_error(pretty_bytes(NA), 'is.numeric.*is not TRUE')

  expect_equal(pretty_bytes(NaN), "NaN B")

})

test_that("pretty_bytes handles vectors", {

  expect_equal(pretty_bytes(1:10), paste(format(1:10), "B"))
  v <- c(NA, 1, 1e4, 1e6, NaN, 1e5)

  expect_equal(pretty_bytes(v),
    c("  NA B", "   1 B", " 10 kB", "  1 MB", " NaN B", "100 kB"))

  expect_equal(pretty_bytes(numeric()), character())
})

test_that("pretty_bytes nopad style", {

  v <- c(NA, 1, 1e4, 1e6, NaN, 1e5)
  expect_equal(pretty_bytes(v, style = "nopad"),
    c("NA B", "1 B", "10 kB", "1 MB", "NaN B", "100 kB"))
  expect_equal(pretty_bytes(numeric(), style = "nopad"), character())
})

test_that("pretty_bytes handles negative values", {
  v <- c(NA, -1, 1e4, 1e6, NaN, -1e5)
  expect_equal(pretty_bytes(v),
    c("   NA B", "   -1 B", "  10 kB", "   1 MB", "  NaN B", "-100 kB"))

})

test_that("always two fraction digits", {
  expect_equal(
    pretty_bytes(c(5.6, 5, NA) * 1000 * 1000),
    c("5.60 MB", "   5 MB", "   NA B")
  )
})

test_that("6 width style", {
  cases <- c(
    "< 0 kB" = -1e4,                    # 1
    "< 0 kB" = -100,                    # 2
    "< 0 kB" = -1,                      # 3
    "0.0 kB" = 0,                       # 4
    "0.0 kB" = 1,                       # 5
    "0.0 kB" = 9,                       # 6
    "0.0 kB" = 9.99999,                 # 7
    "0.0 kB" = 10.33333,                # 8
    "0.1 kB" = 100,                     # 9
    "0.1 kB" = 111.33333,               # 10
    "1.0 kB" = 1e3,                     # 11
    "1.0 kB" = 1049,                    # 12
    "1.1 kB" = 1051,                    # 13
    "1.1 kB" = 1100,                    # 14
    " 10 kB" = 1e4,                     # 15
    "100 kB" = 1e5,                     # 16
    "1.0 MB" = 1e6,                     # 17
    "NaN kB" = NaN,                     # 18
    " NA kB" = NA                       # 19
  )

  expect_equal(pretty_bytes(unname(cases), style = "6"), names(cases))
})

test_that("No fractional bytes (#23)", {
  cases <- c(
    "    -1 B" = -1,                   # 1
    "     1 B" = 1,                    # 2
    "    16 B" = 16,                   # 3
    "   128 B" = 128,                  # 4
    " 1.02 kB" = 1024,                 # 5
    "16.38 kB" = 16384,                # 6
    " 1.05 MB" = 1048576,              # 7
    "-1.05 MB" = -1048576,             # 8
    "    NA B" = NA                    # 9
  )

  expect_equal(pretty_bytes(unname(cases)), names(cases))
})
