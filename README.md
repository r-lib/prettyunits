


<!-- badges: start -->
[![R-CMD-check](https://github.com/r-lib/prettyunits/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/prettyunits/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/r-lib/prettyunits/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/prettyunits?branch=main)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/prettyunits)](https://CRAN.R-project.org/package=prettyunits)
<!-- badges: end -->

# prettyunits

The `prettyunits` package formats quantities in human readable form.
* Time intervals: '1337000' -> '15d 11h 23m 20s'.
* Vague time intervals: '2674000' -> 'about a month ago'.
* Bytes: '1337' -> '1.34 kB'.
* Rounding: '99' with 3 significant digits -> '99.0'
* p-values: '0.00001' -> '<0.0001'.
* Colors: '#FF0000' -> 'red'.
* Quantities: '1239437' -> '1.24 M'.

## Installation

You can install the package from CRAN:


```r
install.packages("prettyunits")
```

If you need the development version, install it from GitHub:


```r
pak::pak("r-lib/prettyunits")
```


```r
library(prettyunits)
library(magrittr)
```

## Bytes

`pretty_bytes` formats number of bytes in a human readable way:


```r
pretty_bytes(1337)
```

```
##> [1] "1.34 kB"
```

```r
pretty_bytes(133337)
```

```
##> [1] "133.34 kB"
```

```r
pretty_bytes(13333337)
```

```
##> [1] "13.33 MB"
```

```r
pretty_bytes(1333333337)
```

```
##> [1] "1.33 GB"
```

```r
pretty_bytes(133333333337)
```

```
##> [1] "133.33 GB"
```

Here is a simple function that emulates the Unix `ls` command, with
nicely formatted file sizes:


```r
uls <- function(path = ".") {
  files <- dir(path)
  info <- files %>%
    lapply(file.info) %>%
    do.call(what = rbind)
  info$size <- pretty_bytes(info$size)
  df <- data.frame(d = ifelse(info$isdir, "d", " "),
	mode = as.character(info$mode), user = info$uname, group = info$grname,
    size = ifelse(info$isdir, "", info$size), modified = info$mtime, name = files)
  print(df, row.names = FALSE)
}
uls()
```

```
##>  d mode        user group    size            modified        name
##>     644 gaborcsardi staff   232 B 2023-09-24 11:37:28 codecov.yml
##>  d  755 gaborcsardi staff         2023-09-24 11:37:28    data-raw
##>     644 gaborcsardi staff 1.12 kB 2023-09-24 11:38:40 DESCRIPTION
##>     644 gaborcsardi staff    42 B 2022-06-17 13:59:46     LICENSE
##>     644 gaborcsardi staff   111 B 2023-09-23 16:44:21    Makefile
##>  d  755 gaborcsardi staff         2023-09-24 11:37:28         man
##>     644 gaborcsardi staff   523 B 2023-09-24 11:37:28   NAMESPACE
##>     644 gaborcsardi staff 1.66 kB 2023-09-24 11:41:10     NEWS.md
##>  d  755 gaborcsardi staff         2023-09-24 11:50:18           R
##>     644 gaborcsardi staff 5.36 kB 2023-09-24 11:46:30   README.md
##>     644 gaborcsardi staff 5.37 kB 2023-09-24 11:50:48  README.Rmd
##>  d  755 gaborcsardi staff         2022-06-17 13:59:46       tests
```

## Quantities

`pretty_num` formats number related to linear quantities in a human readable way:

```r
pretty_num(1337)
```

```
##> [1] "1.34 k"
```

```r
pretty_num(-133337)
```

```
##> [1] "-133.34 k"
```

```r
pretty_num(1333.37e-9)
```

```
##> [1] "1.33 u"
```
Be aware that the result is wrong in case of surface or volumes, and for any non-linear quantity.

Here is a simple example of how to prettify a entire tibble

```r
library(tidyverse)
```

```
##> ── Attaching core tidyverse packages ─────────────────────────────────────────────────────────────────────────── tidyverse 2.0.0 ──
##> ✔ dplyr     1.1.2     ✔ readr     2.1.4
##> ✔ forcats   1.0.0     ✔ stringr   1.5.0
##> ✔ ggplot2   3.4.2     ✔ tibble    3.2.1
##> ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
##> ✔ purrr     1.0.1     
##> ── Conflicts ───────────────────────────────────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
##> ✖ tidyr::extract()   masks magrittr::extract()
##> ✖ dplyr::filter()    masks stats::filter()
##> ✖ dplyr::lag()       masks stats::lag()
##> ✖ purrr::set_names() masks magrittr::set_names()
##> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
```

```r
tdf <- tribble( ~name, ~`size in m`, ~`speed in m/s`,
                "land snail", 0.075, 0.001,
                "photon", NA,  299792458,
                "African plate", 10546330, 0.000000000681)
tdf %>% mutate(across(where(is.numeric), pretty_num))
```

```
##> # A tibble: 3 × 3
##>   name          `size in m` `speed in m/s`
##>   <chr>         <chr>       <chr>         
##> 1 land snail    "   75 m"   "     1 m"    
##> 2 photon        "    NA "   "299.79 M"    
##> 3 African plate "10.55 M"   "   681 p"
```
You may want to use non-breakable space so that the unit prefix is never separated from the number in space constrained situation like text hover or text labels:

```r
pretty_num(1333.37e-9 , sep = "\xC2\xA0")
```

```
##> [1] "1.33 u"
```


### Quantitiies of class `units`

`pretty_num` loosely preserves units associated with a quantity: 

```r
library(units)
```

```
##> Warning: package 'units' was built under R version 3.6.2
```

```
##> udunits system database from /Library/Frameworks/R.framework/Versions/3.6/Resources/library/units/share/udunits
```

```r
l_cm <- set_units(1337129, cm)
pretty_num(l_cm)
```

```
##> [1] "1.34 M [cm]"
```
So it is up to you to turn the unit into the right [base-unit](https://en.wikipedia.org/wiki/SI_base_unit)

If you do so, then the best prefix is potentially moved to the units : 

```r
pretty_num(l_cm %>% set_units(m))
```

```
##> [1] "13.37 [km]"
```

If you try non-linear units, you should get an error:
```
surface <- set_units(1337129, "m2")
pretty_num(surface)
```
```
##> Error in compute_num(number) : pretty_num() doesn't handle non-linear units
```

This can be used for an entire data-frame as well

```r
names(tdf) <- c( "name", "size", "speed" )
units(tdf$size) <- "m"
units(tdf$speed) <- "m/s"
tdf %>% mutate(across(where(is.numeric), pretty_num))
```

```
##> # A tibble: 3 x 3
##>   name          size          speed           
##>   <chr>         <chr>         <chr>           
##> 1 land snail    "   75 m [m]" "     1 m [m/s]"
##> 2 photon        "    NA  [m]" "299.79 M [m/s]"
##> 3 African plate "10.55 M [m]" "   681 p [m/s]"
```
