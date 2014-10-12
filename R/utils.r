
#' @importFrom assertthat assert_that is.string

`%s%` <- function(lhs, rhs) {
  assert_that(is.string(lhs))
  list(lhs) %>%
    c(as.list(rhs)) %>%
    do.call(what = sprintf)
}

`%+%` <- function(lhs, rhs) {
  paste0(lhs, rhs)
}

assert_diff_time <- function(x) {
  stopifnot(inherits(x, "difftime"))
}
