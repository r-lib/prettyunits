#' Round a value to a defined number of digits printing out trailing zeros, if
#' applicable
#'
#' @details Values that are not standard numbers like `Inf`, `NA`, and
#'   `NaN` are returned as `"Inf"`, `"NA"`, and `"NaN"`.
#'
#' @param x The number to round.
#' @param digits integer indicating the number of decimal places.  Non-integer
#'   values are rounded to the nearest integer.
#' @param sci_range See help for [pretty_signif()] (and you likely want
#'   to round with [pretty_signif()] if you want to use this argument).
#' @param sci_sep The separator to use for scientific notation strings
#'   (typically this will be either "e" or "x10^" for computer- or
#'   human-readable output).
#' @return A string with the value.
#' @seealso [round()], [pretty_signif()].
#' @export

pretty_round <- function(x, digits = 0, sci_range = Inf, sci_sep = "e") {
  check_rounding_args(digits = digits, sci_range = sci_range, sci_sep = sci_sep)
  digits <- round(digits)
  if (!(length(digits) == 1 || length(digits) == length(x))) {
    stop("digits must either be a scalar or the same length as x")
  }
  if (length(x) == 0) {
    return(restore_shape(character(0), x))
  }
  if (length(digits) == 1) {
    mask_na <- is.na(x)
    mask_aschar <- is.nan(x) | is.infinite(x)
    mask_manip <- !(mask_na | mask_aschar)
    ret <- rep(NA_character_, length(x))
    ## Put in the special values
    if (any(mask_na)) {
      ret[mask_na] <- "NA"
    }
    if (any(mask_aschar)) {
      ret[mask_aschar] <- as.character(x[mask_aschar])
    }
    if (any(mask_manip)) {
      xtmp <- round(x[mask_manip], digits)
      mask_sci <-
        xtmp != 0 &
        abs(log10(abs(xtmp))) >= sci_range
      mask_no_sci <- !mask_sci
      if (any(mask_sci)) {
        logval <- floor(log10(abs(xtmp[mask_sci])))
        ret[mask_manip][mask_sci] <-
          format_sci(
            xtmp[mask_sci],
            digits = digits + logval,
            sci_sep = sci_sep
          )
      }
      if (any(mask_no_sci)) {
        ret[mask_manip][mask_no_sci] <-
          format_fixed(xtmp[mask_no_sci], digits = digits)
      }
    }
    restore_shape(ret, x)
  } else {
    ret <-
      mapply(
        pretty_round,
        x,
        digits = digits,
        sci_range = sci_range,
        sci_sep = sci_sep,
        USE.NAMES = FALSE
      )
    restore_shape(ret, x)
  }
}

#' Round a value to a defined number of significant digits printing out trailing
#' zeros, if applicable
#'
#' @details Values that are not standard numbers like `Inf`, `NA`, and
#'   `NaN` are returned as `"Inf"`, `"NA"`, and `NaN`.
#'
#' @param x The number to round.
#' @param digits integer indicating the number of significant digits.
#'   Non-integer values are rounded to the nearest integer, and as with
#'   [signif()], values smaller than 1 are treated as 1 (with a warning).
#' @param sci_range integer (or `Inf`) indicating when to switch to
#'   scientific notation instead of floating point. Zero indicates always use
#'   scientific; `Inf` indicates to never use scientific notation;
#'   otherwise, scientific notation is used when `abs(log10(x)) > sci_range`.
#' @param sci_sep The separator to use for scientific notation strings
#'   (typically this will be either "e" or "x10^" for computer- or
#'   human-readable output).
#' @return A string with the value.
#' @seealso [signif()], [pretty_round()].
#' @export

pretty_signif <- function(x, digits = 6, sci_range = 6, sci_sep = "e") {
  check_rounding_args(digits = digits, sci_range = sci_range, sci_sep = sci_sep)
  digits <- round(digits)
  if (!(length(digits) == 1 || length(digits) == length(x))) {
    stop("digits must either be a scalar or the same length as x")
  }
  if (any(digits < 1)) {
    warning("digits values smaller than 1 are treated as 1")
    digits <- pmax(digits, 1)
  }
  digits <- rep_len(digits, length(x))
  mask_na <- is.na(x)
  mask_aschar <- is.nan(x) | is.infinite(x)
  mask_manip <- !(mask_na | mask_aschar)
  ret <- rep(NA_character_, length(x))
  ## Put in the special values
  if (any(mask_na)) {
    ret[mask_na] <- "NA"
  }
  if (any(mask_aschar)) {
    ret[mask_aschar] <- as.character(x[mask_aschar])
  }
  if (any(mask_manip)) {
    xtmp <- x[mask_manip]
    digits_manip <- digits[mask_manip]
    toplog <- bottomlog <- rep(NA, length(xtmp))
    ## When 0 give the digits as the output
    bottomlog[xtmp %in% 0] <- digits_manip[xtmp %in% 0]
    ## Otherwise set it to digits orders of magnitude lower than the
    ## current value
    toplog <- log10(abs(xtmp))
    ## When the order of magnitude is an exact log 10, move up one so
    ## that the math works for determing the lower log.
    mask.exact.log <- (toplog %% 1) %in% 0
    toplog[mask.exact.log] <- toplog[mask.exact.log] + 1
    toplog <- ceiling(toplog)
    bottomlog[is.na(bottomlog)] <-
      digits_manip[is.na(bottomlog)] - toplog[is.na(bottomlog)]
    ## Find times when rounding increases the toplog and shift up the
    ## bottomlog to a corresponding degree. e.g. x=0.9999 and digits=2
    ## should be 1.0 not 1.00.
    newtoplog <- log10(abs(round(xtmp, digits = bottomlog)))
    mask.exact.log <- (newtoplog %% 1) %in% 0
    newtoplog[mask.exact.log] <- newtoplog[mask.exact.log] + 1
    newtoplog <- ceiling(newtoplog)
    mask.move.up <- toplog < newtoplog
    bottomlog[mask.move.up] <- bottomlog[mask.move.up] - 1
    ## Do the rounding
    ret[mask_manip] <- pretty_round(
      xtmp,
      digits = bottomlog,
      sci_range = sci_range,
      sci_sep = sci_sep
    )
  }
  restore_shape(ret, x)
}

## Argument checks shared by pretty_round() and pretty_signif()
check_rounding_args <- function(digits, sci_range, sci_sep) {
  if (!is.numeric(digits) || any(!is.finite(digits))) {
    stop("digits must be finite and numeric")
  }
  if (!is.numeric(sci_range) || length(sci_range) != 1 || is.na(sci_range)) {
    stop("sci_range must be a scalar, non-missing number")
  }
  if (!is.character(sci_sep) || length(sci_sep) != 1 || is.na(sci_sep)) {
    stop("sci_sep must be a scalar, non-missing character string")
  }
}

## Give the result the names or dim of x, as formatC() does
restore_shape <- function(ret, x) {
  if (is.null(dim(x))) {
    names(ret) <- names(x)
  } else {
    dim(ret) <- dim(x)
    dimnames(ret) <- dimnames(x)
  }
  ret
}

## Significant decimal digits needed to reproduce any double
max_digits <- 17

## The fewest significant digits that reproduce x exactly
signif_digits <- function(x) {
  ret <- rep(max_digits, length(x))
  for (d in (max_digits - 1):1) {
    ret[as.numeric(sprintf("%.*e", d - 1, x)) == x] <- d
  }
  ret
}

## Take the mantissa and the exponent from sprintf() rather than dividing by
## 10^logval, which underflows in the denormal range and can leave a mantissa
## of 10 or more.  Digits past the ones x determines are zeros rather than the
## binary representation of x.
format_sci <- function(x, digits, sci_sep) {
  n_dec <- pmin(digits, signif_digits(x) - 1)
  sci <- sprintf("%.*e", n_dec, x)
  paste0(
    sub("e.*$", "", sci),
    ifelse(n_dec == 0 & digits > 0, ".", ""),
    zeros(digits - n_dec),
    sci_sep,
    formatC(as.integer(sub("^.*e", "", sci)), format = "d")
  )
}

## sprintf() prints the exact decimal expansion of the double, which past
## max_digits is the binary representation rather than zeros
format_fixed <- function(x, digits) {
  digits <- pmax(digits, 0)
  exponent <- floor(log10(abs(x)))
  mask_exact <- !is.finite(exponent) | exponent + 1 + digits <= max_digits
  ret <- rep(NA_character_, length(x))
  ret[mask_exact] <- sprintf("%.*f", digits, x[mask_exact])
  ret[!mask_exact] <- expand_sci(x[!mask_exact], digits = digits)
  ret
}

## Shift the decimal point of the digits x determines and pad with zeros
expand_sci <- function(x, digits) {
  sci <- sprintf("%.*e", signif_digits(x) - 1, x)
  mantissa <- gsub("[-.]", "", sub("e.*$", "", sci))
  int_len <- as.integer(sub("^.*e", "", sci)) + 1
  int_part <-
    ifelse(
      int_len < 1,
      "0",
      paste0(substr(mantissa, 1, int_len), zeros(int_len - nchar(mantissa)))
    )
  frac_part <-
    ifelse(
      int_len < 1,
      paste0(zeros(-int_len), mantissa),
      substr(mantissa, int_len + 1, nchar(mantissa))
    )
  paste0(
    ifelse(x < 0, "-", ""),
    int_part,
    ifelse(digits > 0, ".", ""),
    frac_part,
    zeros(digits - nchar(frac_part))
  )
}

## A run of n zeros, vectorized over n
zeros <- function(n) {
  substr(rep(paste(rep("0", max(c(n, 0))), collapse = ""), length(n)), 1, n)
}
