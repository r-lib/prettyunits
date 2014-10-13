
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

pretty_bytes <- function(bytes) {

  stopifnot(is.numeric(bytes))

  units <- c('B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')

  neg <- bytes < 0 & !is.na(bytes)
  bytes <- abs(bytes)

  exponent <- pmin(floor(log(bytes, 1000)), length(units) - 1)
  res <- round(bytes / 1000 ^ exponent, 2)
  unit <- units[exponent + 1]

  ## Zero bytes
  res[bytes == 0] <- 0
  unit[bytes == 0] <- units[1]

  ## NA and NaN bytes
  res[is.na(bytes)] <- NA_real_
  res[is.nan(bytes)] <- NaN
  unit[is.na(bytes)] <- "B"            # Includes NaN as well

  ## String
  res <- format(ifelse(neg, -1, 1) * res, scientific = FALSE)

  "%s %s" %s% list(res, unit)
}
