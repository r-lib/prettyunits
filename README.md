
<!-- badges: start -->

[![R-CMD-check](https://github.com/r-lib/prettyunits/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/prettyunits/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/prettyunits/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/prettyunits?branch=main)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/prettyunits)](https://CRAN.R-project.org/package=prettyunits)
<!-- badges: end -->

# prettyunits

The `prettyunits` package formats quantities in human readable form.

-   Time intervals: ‘1337000’ -> ‘15d 11h 23m 20s’.
-   Vague time intervals: ‘2674000’ -> ‘about a month ago’.
-   Bytes: ‘1337’ -> ‘1.34 kB’.
-   Rounding: ‘99’ with 3 significant digits -> ‘99.0’
-   p-values: ‘0.00001’ -> ‘\<0.0001’.
-   Colors: ‘#FF0000’ -> ‘red’.
-   Quantities: ‘1239437’ -> ‘1.24 M’.

## Installation

You can install the package from CRAN:

``` r
install.packages("prettyunits")
```

If you need the development version, install it from GitHub:

``` r
pak::pak("r-lib/prettyunits")
```

## Bytes

`pretty_bytes` formats number of bytes in a human readable way:

``` r
pretty_bytes(1337)
```

    ##> [1] "1.34 kB"

``` r
pretty_bytes(133337)
```

    ##> [1] "133.34 kB"

``` r
pretty_bytes(13333337)
```

    ##> [1] "13.33 MB"

``` r
pretty_bytes(1333333337)
```

    ##> [1] "1.33 GB"

``` r
pretty_bytes(133333333337)
```

    ##> [1] "133.33 GB"

Here is a simple function that emulates the Unix `ls` command, with
nicely formatted file sizes:

``` r
uls <- function(path = ".") {
  files <- dir(path)
  info <- files |>
    lapply(file.info) |>
    do.call(what = rbind)
  info$size <- pretty_bytes(info$size)
  df <- data.frame(d = ifelse(info$isdir, "d", " "),
    mode = as.character(info$mode), user = info$uname, group = info$grname,
    size = ifelse(info$isdir, "", info$size), modified = info$mtime, name = files)
  print(df, row.names = FALSE)
}
uls()
```

    ##>  d mode        user group      size            modified         name
    ##>     644 gaborcsardi staff     264 B 2025-04-26 17:24:48 _pkgdown.yml
    ##>     644 gaborcsardi staff       0 B 2025-04-28 09:00:42     air.toml
    ##>     644 gaborcsardi staff     232 B 2023-09-24 11:37:28  codecov.yml
    ##>  d  755 gaborcsardi staff           2023-09-24 11:37:28     data-raw
    ##>     644 gaborcsardi staff   1.26 kB 2025-04-28 09:00:33  DESCRIPTION
    ##>     644 gaborcsardi staff      49 B 2025-04-26 17:24:48      LICENSE
    ##>     644 gaborcsardi staff   1.08 kB 2025-04-26 17:24:48   LICENSE.md
    ##>     644 gaborcsardi staff     111 B 2023-09-23 16:44:21     Makefile
    ##>  d  755 gaborcsardi staff           2025-04-28 09:00:33          man
    ##>     644 gaborcsardi staff     391 B 2025-04-26 17:24:39    NAMESPACE
    ##>     644 gaborcsardi staff   1.55 kB 2025-04-28 09:00:33      NEWS.md
    ##>  d  755 gaborcsardi staff           2025-04-28 09:00:33            R
    ##>     644 gaborcsardi staff 641.02 kB 2023-09-24 12:15:16  README.html
    ##>     644 gaborcsardi staff   7.88 kB 2025-04-28 09:00:22    README.md
    ##>     644 gaborcsardi staff   4.46 kB 2025-04-28 09:02:10   README.Rmd
    ##>  d  755 gaborcsardi staff           2025-04-26 17:24:48        tests

## Quantities

`pretty_num` formats number related to linear quantities in a human
readable way:

``` r
pretty_num(1337)
```

    ##> [1] "1.34 k"

``` r
pretty_num(-133337)
```

    ##> [1] "-133.34 k"

``` r
pretty_num(1333.37e-9)
```

    ##> [1] "1.33 u"

Be aware that the result is wrong in case of surface or volumes, and for
any non-linear quantity.

Here is a simple example of how to prettify a entire tibble

``` r
library(tidyverse)
```

    ##> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ##> ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ##> ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ##> ✔ ggplot2   3.5.2     ✔ tibble    3.2.1
    ##> ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
    ##> ✔ purrr     1.0.4     
    ##> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ##> ✖ tidyr::extract()   masks magrittr::extract()
    ##> ✖ dplyr::filter()    masks stats::filter()
    ##> ✖ dplyr::lag()       masks stats::lag()
    ##> ✖ purrr::set_names() masks magrittr::set_names()
    ##> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
tdf <- tribble( ~name, ~`size in m`, ~`speed in m/s`,
                "land snail", 0.075, 0.001,
                "photon", NA,  299792458,
                "African plate", 10546330, 0.000000000681)
tdf |> mutate(across(where(is.numeric), pretty_num))
```

    ##> # A tibble: 3 × 3
    ##>   name          `size in m` `speed in m/s`
    ##>   <chr>         <chr>       <chr>         
    ##> 1 land snail    "   75 m"   "     1 m"    
    ##> 2 photon        "    NA "   "299.79 M"    
    ##> 3 African plate "10.55 M"   "   681 p"

## Time intervals

`pretty_ms` formats a time interval given in milliseconds. `pretty_sec`
does the same for seconds, and `pretty_dt` for `difftime` objects. The
optional `compact` argument turns on a compact, approximate format.

``` r
pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000))
```

    ##> [1] "1.3s"            "13.4s"           "2m 13.7s"        "22m 17s"        
    ##> [5] "15d 11h 23m 20s"

``` r
pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000),
  compact = TRUE)
```

    ##> [1] "~1.3s"  "~13.4s" "~2m"    "~22m"   "~15d"

``` r
pretty_sec(c(1337, 13370, 133700, 1337000, 13370000))
```

    ##> [1] "22m 17s"          "3h 42m 50s"       "1d 13h 8m 20s"    "15d 11h 23m 20s" 
    ##> [5] "154d 17h 53m 20s"

``` r
pretty_sec(c(1337, 13370, 133700, 1337000, 13370000),
  compact = TRUE)
```

    ##> [1] "~22m"  "~3h"   "~1d"   "~15d"  "~154d"

## Vague time intervals

`vague_dt` and `time_ago` formats time intervals using a vague format,
omitting smaller units. They both have three formats: `default`, `short`
and `terse`. `vague_dt` takes a `difftime` object, and `time_ago` works
relatively to the specified date.

``` r
vague_dt(format = "short", as.difftime(30, units = "secs"))
```

    ##> [1] "<1 min"

``` r
vague_dt(format = "short", as.difftime(14, units = "mins"))
```

    ##> [1] "14 min"

``` r
vague_dt(format = "short", as.difftime(5, units = "hours"))
```

    ##> [1] "5 hours"

``` r
vague_dt(format = "short", as.difftime(25, units = "hours"))
```

    ##> [1] "1 day"

``` r
vague_dt(format = "short", as.difftime(5, units = "days"))
```

    ##> [1] "5 day"

``` r
now <- Sys.time()
time_ago(now)
```

    ##> [1] "moments ago"

``` r
time_ago(now - as.difftime(30, units = "secs"))
```

    ##> [1] "less than a minute ago"

``` r
time_ago(now - as.difftime(14, units = "mins"))
```

    ##> [1] "14 minutes ago"

``` r
time_ago(now - as.difftime(5, units = "hours"))
```

    ##> [1] "5 hours ago"

``` r
time_ago(now - as.difftime(25, units = "hours"))
```

    ##> [1] "a day ago"

## Rounding

`pretty_round()` and `pretty_signif()` preserve trailing zeros.

``` r
pretty_round(1, digits=6)
```

    ##> [1] "1.000000"

``` r
pretty_signif(c(99, 0.9999), digits=3)
```

    ##> [1] "99.0" "1.00"

## p-values

`pretty_p_value()` rounds small p-values to indicate less than
significance level for small values.

``` r
pretty_p_value(c(0.05, 0.0000001, NA))
```

    ##> [1] "0.0500"  "<0.0001" NA

## Colors

`pretty_color` converts colors from other representations to
human-readable names.

``` r
pretty_color("black")
```

    ##> [1] "black"
    ##> attr(,"alt")
    ##> [1] "black" "gray0" "grey0" "Black"

``` r
pretty_color("#123456")
```

    ##> [1] "Prussian Blue"
    ##> attr(,"alt")
    ##> [1] "Prussian Blue"
