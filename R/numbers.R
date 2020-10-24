
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
    units0 <- c("p","n","μ","m","", "k", "M", "G", "T", "P", "E", "Z", "Y")

    stopifnot(
      is.numeric(number),
      is.character(smallest_unit),
      length(smallest_unit) == 1,
      !is.na(smallest_unit),
      smallest_unit %in% units0
    )

    limits <- c(1000, 999950 * 1000 ^ (seq_len(length(units0) - 2) - 1))
    low <- match(smallest_unit, units0)
    units <- units0[low:length(units0)]
    limits <- limits[low:length(limits)]

    neg <- number < 0 & !is.na(number)
    number <- abs(number)

    mat <- matrix(
      rep(number, each = length(limits)),
      nrow = length(limits),
      ncol = length(number)
    )
    mat2 <- matrix(mat < limits, nrow  = length(limits), ncol = length(number))
    exponent <- length(limits) - colSums(mat2) + low - 1L
    res <- number / 1000 ^ exponent
    unit <- units[exponent - low + 6L]

    ## Zero number
    res[number == 0] <- 0
    unit[number == 0] <- units[1]

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

    ## String. For fractions we always show two fraction digits
    res <- character(length(amt))
    int <- is.na(amt) | amt == as.integer(amt)
    res[int] <- format(
      ifelse(szs$negative[int], -1, 1) * amt[int],
      scientific = FALSE
    )
    res[!int] <- sprintf("%.2f", ifelse(szs$negative[!int], -1, 1) * amt[!int])

    format(paste(res, szs$unit), justify = "right")
  }

  pretty_num_nopad <- function(number) {
    sub("^\\s+", "", pretty_num_default(number))
  }

  pretty_num_6 <- function(number) {
    szs <- compute_num(number, smallest_unit = "p")
    amt <- szs$amount

    na   <- is.na(amt)
    nan  <- is.nan(amt)
    neg  <- !na & !nan & szs$negative
    l10  <- !na & !nan & !neg & amt < 10
    l100 <- !na & !nan & !neg & amt >= 10 & amt < 100
    b100 <- !na & !nan & !neg & amt >= 100

    szs$unit[neg] <- "kB"

    famt <- character(length(amt))
    famt[na] <- " NA"
    famt[nan] <- "NaN"
    famt[neg] <- "< 0"
    famt[l10] <- sprintf("%.1f", amt[l10])
    famt[l100] <- sprintf(" %.0f", amt[l100])
    famt[b100] <- sprintf("%.0f", amt[b100])

    paste0(famt, " ", szs$unit)
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
