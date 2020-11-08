format_num <- local({

  pretty_num <- function(number, style = c("default", "nopad", "6"), sep = "\xC2\xA0") {

    style <- switch(
      match.arg(style),
      "default" = pretty_num_default,
      "nopad" = pretty_num_nopad,
      "6" = pretty_num_6
    )
    stopifnot(!is.na(sep))
    style(number, sep)
  }

  compute_num <- function(number, smallest_prefix = "y") {
    prefixes0 <- c("y","z","a","f","p","n","\xC2\xB5","m","", "k", "M", "G", "T", "P", "E", "Z", "Y")
    zeroshif0 <- 9L
    
    stopifnot(
      is.numeric(number),
      is.character(smallest_prefix),
      length(smallest_prefix) == 1,
      !is.na(smallest_prefix),
      smallest_prefix %in% prefixes0
    )
    
    limits <- c( 999950 * 1000 ^ (seq_len(length(prefixes0) ) - (zeroshif0+1L)))
    nrow <- length(limits)
    low <- match(smallest_prefix, prefixes0)
    zeroshift <- zeroshif0 +1L - low
    prefixes <- prefixes0[low:length(prefixes0)]
    limits <- limits[low:nrow]

    neg <- number != abs(number) & !is.na(number)
    number <- abs(number)
    mat <- matrix(
      rep(number, each = nrow),
      nrow = nrow,
      ncol = length(number)
    )
    mat2 <- matrix(mat < limits, nrow  = nrow, ncol = length(number))
    exponent <- nrow - colSums(mat2) - (zeroshift -1L)
    ## enforce exponent to be in range of prefixes limits
    in_range <- function(exponent) {
        max(min(exponent,nrow-zeroshift, na.rm = FALSE),1L-zeroshift, na.rm = TRUE)
    }
    if (length(exponent)) {
      exponent <- sapply(exponent, in_range)
    }
    prefix <- prefixes[exponent + zeroshift]

    ## Change unit with majority prefix if convertible and exponent accordingly
    is_unit=FALSE
    if (length(attr(number,"units"))) {
      is_unit = TRUE
      # test if numerator is not linear unit and exit with error
      if (max(table(attr(number,"units")$numerator)>1 )) {
        stop("pretty_num() doesn't handle non-linear units")
      }
      number_unit <- units::deparse_unit(number)
      prefix_table <- sort(table(prefix[prefix !=""]),decreasing = T)
      majority_prefix <- ifelse(prefix_table[1] >= sum(prefix_table)/2, as.character(names(prefix_table[1])), "")
      majority_unit <- paste0(majority_prefix, number_unit)
      if (units:::ud_are_convertible(number_unit, majority_unit)) {
        # change unit to majority_unit
        units(number) <- majority_unit
        # shift exponent and prefix in_range accordingly
        exponent <- exponent - (match(majority_prefix, prefixes) - zeroshift)
        if (length(exponent)) {
          exponent <- sapply(exponent, in_range)
        }
        prefix <- prefixes[exponent + zeroshift]
        number_unit <- units::deparse_unit(number)
      }
    }
    
    amount <- number / 1000 ^ exponent

    ## Zero number, with set_units to copy the units from number to 0
    amount[as.numeric(number)==0] <- ifelse(is_unit, units::set_units(0, number_unit, mode = "standard"), 0)
    prefix[as.numeric(number)==0] <- ""

    ## NA and NaN number
    amount[is.na(number)] <- NA_real_
    amount[is.nan(number)] <- NaN
    prefix[is.na(number)] <- "" # prefixes0[low] is meaningless    # Includes NaN as well

    data.frame(
      stringsAsFactors = FALSE,
      amount = amount,
      prefix = prefix,
      negative = neg
    )
  }

  pretty_num_default <- function(number, sep) {
    szs <- compute_num(number)
    amt <- szs$amount

    ## String. For fractions we always show two fraction digits
    res <- character(length(amt))
    int <- is.na(amt) | as.numeric(amt) == as.integer(amt)
    res[int] <- format(
      ifelse(szs$negative[int], -1, 1) * as.numeric(amt[int]),
      scientific = FALSE
    )
    res[!int] <- sprintf("%.2f", ifelse(szs$negative[!int], -1, 1) * amt[!int])
    sep <- ifelse(is.na(res), NA_character_, sep)
    pretty_num <- paste0(res, sep, szs$prefix)
    if(length(attr(number,"units"))){
      pretty_num <- paste0(pretty_num,units::make_unit_label("", amt, parse=FALSE))
    }
    # remove units added space if any
    sub("(?<=\\d\\s)\\s","", format(pretty_num, justify = "right"), perl=TRUE)
  }

  pretty_num_nopad <- function(number, sep) {
    sub("^\\s+", "", pretty_num_default(number, sep))
  }

  pretty_num_6 <- function(number, sep) {
    szs <- compute_num(number, smallest_prefix = "y")
    amt <- round(szs$amount,2)

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

    sub(" $","  ",paste0(famt, sep, szs$prefix))
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
