[![Linux Build
Status](https://travis-ci.org/gaborcsardi/prettyunits.svg?branch=master)](https://travis-ci.org/gaborcsardi/prettyunits)
[![Windows Build
status](https://ci.appveyor.com/api/projects/status/github/gaborcsardi/prettyunits?svg=true)](https://ci.appveyor.com/project/gaborcsardi/prettyunits)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/prettyunits)](http://cran.r-project.org/web/packages/prettyunits/index.html)

prettyunits
===========

The `prettyunits` package formats quantities in human readable form.
Currently time units and information (i.e. bytes) are supported.

Installation
------------

You can install the package from CRAN:

    install.packages("prettyunits")

    library(prettyunits)
    library(magrittr)

Bytes
-----

`pretty_bytes` formats number of bytes in a human readable way:

    pretty_bytes(1337)

    ##> [1] "1.34 kB"

    pretty_bytes(133337)

    ##> [1] "133.34 kB"

    pretty_bytes(13333337)

    ##> [1] "13.33 MB"

    pretty_bytes(1333333337)

    ##> [1] "1.33 GB"

    pretty_bytes(133333333337)

    ##> [1] "133.33 GB"

Here is a simple function that emulates the Unix `ls` command, with
nicely formatted file sizes:

    uls <- function(path = ".") {
      files <- dir(path)
      info <- files %>%
        lapply(file.info) %>%
        do.call(what = rbind)
      info$size <- pretty_bytes(info$size)
      df <-
        data.frame(
          d = ifelse(info$isdir, "d", " "),
          mode = as.character(info$mode),
          user = ifelse(is.null(info$uname), "", info$uname),
          group = ifelse(is.null(info$grname), "", info$grname),
          size = ifelse(info$isdir, "", info$size),
          modified = info$mtime,
          name = files
        )
      print(df, row.names = FALSE)
    }
    uls()

    ##>  d mode user group      size            modified        name
    ##>     666             535.00 B 2019-09-12 16:55:28     NEWS.md
    ##>     666            640.63 kB 2019-09-13 12:14:39 README.html
    ##>     666              4.25 kB 2019-09-12 09:49:50   README.md
    ##>     666              3.40 kB 2019-09-13 12:16:30  README.Rmd

Time intervals
--------------

`pretty_ms` formats a time interval given in milliseconds. `pretty_sec`
does the same for seconds, and `pretty_dt` for `difftime` objects. The
optional `compact` argument turns on a compact, approximate format.

    pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000))

    ##> [1] "1.3s"            "13.4s"           "2m 13.7s"        "22m 17s"        
    ##> [5] "15d 11h 23m 20s"

    pretty_ms(c(1337, 13370, 133700, 1337000, 1337000000),
      compact = TRUE)

    ##> [1] "~1.3s"  "~13.4s" "~2m"    "~22m"   "~15d"

    pretty_sec(c(1337, 13370, 133700, 1337000, 13370000))

    ##> [1] "22m 17s"          "3h 42m 50s"       "1d 13h 8m 20s"   
    ##> [4] "15d 11h 23m 20s"  "154d 17h 53m 20s"

    pretty_sec(c(1337, 13370, 133700, 1337000, 13370000),
      compact = TRUE)

    ##> [1] "~22m"  "~3h"   "~1d"   "~15d"  "~154d"

Vague time intervals
--------------------

`vague_dt` and `time_ago` formats time intervals using a vague format,
omitting smaller units. They both have three formats: `default`, `short`
and `terse`. `vague_dt` takes a `difftime` object, and `time_ago` works
relatively to the specified date.

    vague_dt(format = "short", as.difftime(30, units = "secs"))

    ##> [1] "<1 min"

    vague_dt(format = "short", as.difftime(14, units = "mins"))

    ##> [1] "14 min"

    vague_dt(format = "short", as.difftime(5, units = "hours"))

    ##> [1] "5 hours"

    vague_dt(format = "short", as.difftime(25, units = "hours"))

    ##> [1] "1 day"

    vague_dt(format = "short", as.difftime(5, units = "days"))

    ##> [1] "5 day"

    now <- Sys.time()
    time_ago(now)

    ##> [1] "moments ago"

    time_ago(now - as.difftime(30, units = "secs"))

    ##> [1] "less than a minute ago"

    time_ago(now - as.difftime(14, units = "mins"))

    ##> [1] "14 minutes ago"

    time_ago(now - as.difftime(5, units = "hours"))

    ##> [1] "5 hours ago"

    time_ago(now - as.difftime(25, units = "hours"))

    ##> [1] "a day ago"

Colors
------

`pretty_color` converts colors from other representations to
human-readable names.

    pretty_color("black")

    ##> Loading required namespace: spacesXYZ

    ##> [1] "black"
    ##> attr(,"alt")
    ##> [1] "black" "gray0" "grey0" "Black"

    pretty_color("#123456")

    ##> [1] "black"
    ##> attr(,"alt")
    ##> [1] "black" "gray0" "grey0" "Black"

    pretty_color("#123456", color_set="complete")

    ##> [1] "Prussian Blue"
    ##> attr(,"alt")
    ##> [1] "Prussian Blue"
