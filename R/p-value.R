#' p-values in a human-readable string
#'
#' @param x A numeric vector
#' @param minval The minimum p-value to show (lower values will show as
#'   `paste0("<", minval)`)
#' @return A character vector of p-value representations
#' @examples
#' pretty_p_value(c(
#' @export
#' @importFrom PKNCA roundString
pretty_p_value <- function(x, minval=0.0001) {
  stopifnot(is.numeric(minval) & !is.factor(minval) & !is.na(minval))
  stopifnot(minval < 1 & minval > 0)
  ret <- rep(NA_character_, length(x))
  if (!all(is.na(x))) {
    # The input check on x class and value is here to allow for inputs of all NA
    # values to be of any class.
    stopifnot(is.numeric(x) & !is.factor(x))
    stopifnot(is.na(x) | (x <= 1 & x >= 0))
    ndigits <- -floor(log10(minval))
    mask_min <- !is.na(x) & x < minval
    mask_over <- !is.na(x) & x >= minval
    ret[mask_min] <- paste0("<", PKNCA::roundString(minval, digits=ndigits))
    ret[mask_over] <- PKNCA::roundString(x[mask_over], digits=ndigits)
  }
  ret
}
