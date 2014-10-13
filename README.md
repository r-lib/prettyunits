


[![Linux Build Status](https://travis-ci.org/gaborcsardi/prettyunits.png?branch=master)](https://travis-ci.org/gaborcsardi/prettyunits)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/gaborcsardi/prettyunits)](https://ci.appveyor.com/project/gaborcsardi/prettyunits)


# prettyunits

The `prettyunits` package formats quantities in human readable form. Currently
time units and information (i.e. bytes) are supported.

## Installation

You can install the package from github:


```r
library(devtools)
install_github("gaborcsardi/prettyunits")
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
##>  d mode        user group    size            modified         name
##>     644 gaborcsardi staff   795 B 2014-10-13 09:00:43 appveyor.yml
##>     644 gaborcsardi staff   512 B 2014-10-13 09:04:07  DESCRIPTION
##>     644 gaborcsardi staff    42 B 2014-10-03 15:44:54      LICENSE
##>     644 gaborcsardi staff   111 B 2014-10-12 23:07:32     Makefile
##>  d  755 gaborcsardi staff         2014-10-12 16:51:06          man
##>     644 gaborcsardi staff   259 B 2014-10-12 16:51:39    NAMESPACE
##>  d  755 gaborcsardi staff         2014-10-12 16:47:25            R
##>     644 gaborcsardi staff 4.08 kB 2014-10-12 23:51:28    README.md
##>     644 gaborcsardi staff 2.83 kB 2014-10-13 09:03:08   README.Rmd
##>     644 gaborcsardi staff 3.83 kB 2014-10-13 09:04:02         tags
##>  d  755 gaborcsardi staff         2014-10-12 15:15:48        tests
```

## Time intervals

`pretty_ms` formats a time interval given in milliseconds. `pretty_sec` does
the same for seconds, and `pretty_dt` for `difftime` objects. The optional
`compact` argument turns on a compact, approximate format.


```r
pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000))
```

```
##> [1] "1s 337ms"        "13s 370ms"       "2m 13s 700ms"    "22m 17s"        
##> [5] "15d 11h 23m 20s"
```

```r
pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000),
  compact = TRUE)
```

```
##> [1] "~1s"  "~13s" "~2m"  "~22m" "~15d"
```

```r
pretty_sec(c(1337, 13370, 133700, 1337000, 13370000))
```

```
##> [1] "22m 17s"          "3h 42m 50s"       "1d 13h 8m 20s"   
##> [4] "15d 11h 23m 20s"  "154d 17h 53m 20s"
```

```r
pretty_sec(c(1337, 13370, 133700, 1337000, 13370000),
  compact = TRUE)
```

```
##> [1] "~22m"  "~3h"   "~1d"   "~15d"  "~154d"
```

## Vague time intervals

`vague_dt` and `time_ago` formats time intervals using a vague format,
omitting smaller units. They both have three formats: `default`, `short` and `terse`.
`vague_dt` takes a `difftime` object, and `time_ago` works relatively to the
specified date.


```r
vague_dt(format = "short", as.difftime(30, units = "secs"))
```

```
##> [1] "<1 min"
```

```r
vague_dt(format = "short", as.difftime(14, units = "mins"))
```

```
##> [1] "14 min"
```

```r
vague_dt(format = "short", as.difftime(5, units = "hours"))
```

```
##> [1] "5 hours"
```

```r
vague_dt(format = "short", as.difftime(25, units = "hours"))
```

```
##> [1] "1 day"
```

```r
vague_dt(format = "short", as.difftime(5, units = "days"))
```

```
##> [1] "5 day"
```


```r
now <- Sys.time()
time_ago(now)
```

```
##> [1] "moments ago"
```

```r
time_ago(now - as.difftime(30, units = "secs"))
```

```
##> [1] "less than a minute ago"
```

```r
time_ago(now - as.difftime(14, units = "mins"))
```

```
##> [1] "14 minutes ago"
```

```r
time_ago(now - as.difftime(5, units = "hours"))
```

```
##> [1] "5 hours ago"
```

```r
time_ago(now - as.difftime(25, units = "hours"))
```

```
##> [1] "a day ago"
```


