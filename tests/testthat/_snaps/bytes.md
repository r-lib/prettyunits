# pretty_bytes gives errors on invalid input

    Code
      pretty_bytes("")
    Condition
      Error in `compute_bytes()`:
      ! is.numeric(bytes) is not TRUE
    Code
      pretty_bytes("1")
    Condition
      Error in `compute_bytes()`:
      ! is.numeric(bytes) is not TRUE
    Code
      pretty_bytes(TRUE)
    Condition
      Error in `compute_bytes()`:
      ! is.numeric(bytes) is not TRUE
    Code
      pretty_bytes(list(1, 2, 3))
    Condition
      Error in `compute_bytes()`:
      ! is.numeric(bytes) is not TRUE

# pretty_bytes handles NA and NaN

    Code
      pretty_bytes(NA_character_)
    Condition
      Error in `compute_bytes()`:
      ! is.numeric(bytes) is not TRUE
    Code
      pretty_bytes(NA)
    Condition
      Error in `compute_bytes()`:
      ! is.numeric(bytes) is not TRUE

