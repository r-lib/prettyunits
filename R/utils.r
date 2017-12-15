
#' @importFrom assertthat assert_that is.string

`%s%` <- function(lhs, rhs) {
  assert_that(is.string(lhs))
  do.call(
    sprintf,
    c(list(lhs), as.list(rhs))
  )
}

`%+%` <- function(lhs, rhs) {
  paste0(lhs, rhs)
}

assert_diff_time <- function(x) {
  stopifnot(inherits(x, "difftime"))
}
