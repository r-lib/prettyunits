# pretty_num gives errors on invalid input

    Code
      pretty_num("")
    Condition
      Error in `compute_num()`:
      ! is.numeric(number) is not TRUE
    Code
      pretty_num("1")
    Condition
      Error in `compute_num()`:
      ! is.numeric(number) is not TRUE
    Code
      pretty_num(TRUE)
    Condition
      Error in `compute_num()`:
      ! is.numeric(number) is not TRUE
    Code
      pretty_num(list(1, 2, 3))
    Condition
      Error in `compute_num()`:
      ! is.numeric(number) is not TRUE

# pretty_num handles NA and NaN

    Code
      pretty_num(NA_character_)
    Condition
      Error in `compute_num()`:
      ! is.numeric(number) is not TRUE
    Code
      pretty_num(NA)
    Condition
      Error in `compute_num()`:
      ! is.numeric(number) is not TRUE

