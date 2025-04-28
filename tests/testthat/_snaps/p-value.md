# p-values work

    Code
      pretty_p_value(1, minval = "A")
    Condition
      Error in `pretty_p_value()`:
      ! is.numeric(minval) & !is.factor(minval) & !is.na(minval) is not TRUE
    Code
      pretty_p_value("A")
    Condition
      Error in `pretty_p_value()`:
      ! is.numeric(x) & !is.factor(x) is not TRUE
    Code
      pretty_p_value(1.1)
    Condition
      Error in `pretty_p_value()`:
      ! is.na(x) | (x <= 1 & x >= 0) is not TRUE
    Code
      pretty_p_value(-1)
    Condition
      Error in `pretty_p_value()`:
      ! is.na(x) | (x <= 1 & x >= 0) is not TRUE
    Code
      pretty_p_value(0.5, minval = 0)
    Condition
      Error in `pretty_p_value()`:
      ! minval < 1 & minval > 0 is not TRUE
    Code
      pretty_p_value(0.5, minval = 1)
    Condition
      Error in `pretty_p_value()`:
      ! minval < 1 & minval > 0 is not TRUE

