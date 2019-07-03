`%s%` <- function(lhs, rhs) {
  assert_string(lhs)
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

assert_string <- function(x) {
  stopifnot(is.character(x), length(x) == 1L)
}
