
parse_ms <- function(ms) {
  stopifnot(is.numeric(ms))

  data.frame(
    days = floor(ms / 86400000),
    hours = floor((ms / 3600000) %% 24),
    minutes = floor((ms / 60000) %% 60),
    seconds = round((ms / 1000) %% 60, 1)
  )
}

first_positive <- function(x) which(x > 0)[1]

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#' Pretty formatting of milliseconds
#'
#' @param ms Numeric vector of milliseconds
#' @param compact If true, then only the first non-zero
#'   unit is used. See examples below.
#' @return Character vector of formatted time intervals.
#'
#' @family time
#' @export
#' @examples
#' pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000))
#'
#' pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000),
#'           compact = TRUE)

pretty_ms <- function(ms, compact = FALSE) {

  stopifnot(is.numeric(ms))

  parsed <- parse_ms(ms) %>% t()

  if (compact) {
    units <- c("d", "h", "m", "s")
    parsed2 <- parsed
    parsed2[] <- paste0(parsed, units)
    idx <- apply(parsed, 2, first_positive) %>%
      cbind(seq_len(length(ms)))
    parsed2[idx] %>%
      paste0("~", .)

  } else {

    ## Exact for small ones
    exact <- paste0(ceiling(ms), "ms")

    ## Approximate for others, in seconds
    merge_pieces <- function(pieces) {
      (
        (if (pieces[1]) pieces[1] %+% "d " else "") %+%
        (if (pieces[2]) pieces[2] %+% "h " else "") %+%
        (if (pieces[3]) pieces[3] %+% "m " else "") %+%
        (if (pieces[4]) pieces[4] %+% "s " else "")
      )
    }
    approx <- trim(apply(parsed, 2, merge_pieces))

    ifelse(ms < 1000, exact, approx)
  }
}

#' Pretty formatting of seconds
#'
#' @param sec Numeric vector of seconds.
#' @return Character vector of formatted time intervals.
#'
#' @inheritParams pretty_ms
#' @family time
#' @export
#' @examples
#' pretty_sec(c(1337, 13370, 133700, 1337000, 13370000))
#'
#' pretty_sec(c(1337, 13370, 133700, 1337000, 13370000),
#'            compact = TRUE)

pretty_sec <- function(sec, compact = FALSE) {
  pretty_ms(sec * 1000, compact = compact)
}

#' Pretty formatting of time intervals (difftime objects)
#'
#' @param dt A \code{difftime} object, a vector of time
#'   differences.
#' @return Character vector of formatted time intervals.
#'
#' @inheritParams pretty_ms
#' @family time
#' @export
#' @importFrom methods is
#' @examples
#' pretty_dt(as.difftime(1000, units = "secs"))
#' pretty_dt(as.difftime(0, units = "secs"))

pretty_dt <- function(dt, compact = FALSE) {

  stopifnot(is(dt, "difftime"))

  units(dt) <- "secs"

  as.vector(dt) %>%
    pretty_sec(compact = compact)
}
