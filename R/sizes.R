
#' Bytes in a human readable string
#'
#' @param bytes Numeric vector, number of bytes.
#' @return Character vector, the formatted sizes.
#'
#' @export
#' @examples
#' pretty_bytes(1337)
#' pretty_bytes(133337)
#' pretty_bytes(13333337)
#' pretty_bytes(1333333337)
#' pretty_bytes(133333333337)
#' pretty_bytes(c(1000 * 1000, 1000 * 1000 - 1))

pretty_bytes <- function(bytes) {

  szs <- units_bytes(bytes)
  amt <- szs$amount

  ## String. For fractions we always show two fraction digits
  res <- ifelse(
    is.na(amt) | amt == as.integer(amt),
    format(ifelse(szs$negative, -1, 1) * amt, scientific = FALSE),
    sprintf("%.2f", ifelse(szs$negative, -1, 1) * amt)
  )

  "%s %s" %s% list(res, szs$unit)
}

units_bytes <- function(bytes) {
  stopifnot(is.numeric(bytes))

  units  <- c('B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')
  limits <- c(1000, 999950 * 1000 ^ (seq_len(length(units) - 2) - 1))

  neg <- bytes < 0 & !is.na(bytes)
  bytes <- abs(bytes)

  mat <- matrix(rep(bytes, each = length(limits)), nrow = length(limits))
  exponent <- length(limits) - colSums(mat < limits)
  res <- round(bytes / 1000 ^ exponent, 2)
  unit <- units[exponent + 1]

  ## Zero bytes
  res[bytes == 0] <- 0
  unit[bytes == 0] <- units[1]

  ## NA and NaN bytes
  res[is.na(bytes)] <- NA_real_
  res[is.nan(bytes)] <- NaN
  unit[is.na(bytes)] <- "B"            # Includes NaN as well

  list(amount = res, unit = unit, negative = neg)
}
