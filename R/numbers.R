
format_num <- local({

  pretty_num <- function(number, style = c("default", "nopad", "6")) {

    style <- switch(
      match.arg(style),
      "default" = pretty_num_default,
      "nopad" = pretty_num_nopad,
      "6" = pretty_num_6
    )

    style(number)
  }

  compute_num <- function(number, smallest_unit = "p") {
    units0 <- c("p","n","\xC2\xB5","m","", "k", "M", "G", "T", "P", "E", "Z", "Y")
    zeroshif0 <- 5L
    
    stopifnot(
      is.numeric(number),
      is.character(smallest_unit),
      length(smallest_unit) == 1,
      !is.na(smallest_unit),
      smallest_unit %in% units0
    )
    
    limits <- c( 999950 * 1000 ^ (seq_len(length(units0) ) - (zeroshif0+1L)))
    nrow <- length(limits)
    low <- match(smallest_unit, units0)
    zeroshift <- zeroshif0 +1L - low
    units <- units0[low:length(units0)]
    limits <- limits[low:nrow]
    
    # TODO turn 0 here as a vector with same units as number if units %in% attributes(number)
    
    neg <- number != abs(number) & !is.na(number)
    number <- abs(number)
    mat <- matrix(
      rep(number, each = nrow),
      nrow = nrow,
      ncol = length(number)
    )
    mat2 <- matrix(mat < limits, nrow  = nrow, ncol = length(number))
    exponent <- nrow - colSums(mat2) - (zeroshift -1L)
    in_range <- function(exponent) {
        max(min(exponent,nrow-zeroshift, na.rm = FALSE),1L-zeroshift, na.rm = TRUE)
    }
    if (length(exponent)) {
      exponent <- sapply(exponent, in_range)
    }
    res <- number / 1000 ^ exponent
    unit <- units[exponent + zeroshift]

    ## Zero number, with or without set_units
    res[number == -1*number] <- number-number
    unit[number == -1*number] <- units[zeroshift]

    ## NA and NaN number
    res[is.na(number)] <- NA_real_
    res[is.nan(number)] <- NaN
    unit[is.na(number)] <- "" # units0[low] is meaningless    # Includes NaN as well

    data.frame(
      stringsAsFactors = FALSE,
      amount = res,
      unit = unit,
      negative = neg
    )
  }

  pretty_num_default <- function(number) {
    szs <- compute_num(number)
    amt <- szs$amount
    sep <- " "

    ## String. For fractions we always show two fraction digits
    res <- character(length(amt))
    int <- is.na(amt) | as.numeric(amt) == as.integer(amt)
    res[int] <- format(
      ifelse(szs$negative[int], -1, 1) * amt[int],
      scientific = FALSE
    )
    res[!int] <- sprintf("%.2f", ifelse(szs$negative[!int], -1, 1) * amt[!int])

    format(paste(res, szs$unit,sep = sep), justify = "right")
  }

  pretty_num_nopad <- function(number) {
    sub("^\\s+", "", pretty_num_default(number))
  }

  pretty_num_6 <- function(number) {
    szs <- compute_num(number, smallest_unit = "p")
    amt <- round(szs$amount,2)
    sep <- " "

    na   <- is.na(amt)
    nan  <- is.nan(amt)
    neg  <- !na & !nan & szs$negative
    l10p  <- !na & !nan & !neg & amt < 10
    l100p <- !na & !nan & !neg & amt >= 10 & amt < 100
    b100p <- !na & !nan & !neg & amt >= 100
    l10n  <- !na & !nan & neg & amt < 10
    l100n <- !na & !nan & neg & amt >= 10 & amt < 100
    b100n <- !na & !nan & neg & amt >= 100

    famt <- character(length(amt))
    famt[na] <- "  NA"
    famt[nan] <- " NaN"
    famt[l10p] <- sprintf("%.2f", amt[l10p])
    famt[l100p] <- sprintf("%.1f", amt[l100p])
    famt[b100p] <- sprintf(" %.0f", amt[b100p])
    famt[l10n] <- sprintf("-%.1f", amt[l10n])
    famt[l100n] <- sprintf(" -%.0f", amt[l100n])
    famt[b100n] <- sprintf("-%.0f", amt[b100n])

    sub(" $","  ",paste0(famt, sep, szs$unit))
  }

  structure(
    list(
      .internal     = environment(),
      pretty_num  = pretty_num,
      compute_num = compute_num
    ),
    class = c("standalone_num", "standalone")
  )
})
