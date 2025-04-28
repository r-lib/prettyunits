library(tidyverse)
library(assertr)

# From https://stackoverflow.com/a/57926144/3831096
paste_missing <- function(..., sep = " ", collapse = NULL) {
  ret <-
    apply(
      X = cbind(...),
      MARGIN = 1,
      FUN = function(x) {
        if (all(is.na(x))) {
          NA_character_
        } else {
          paste(x[!is.na(x)], collapse = sep)
        }
      }
    )
  if (!is.null(collapse)) {
    paste(ret, collapse = collapse)
  } else {
    ret
  }
}

color_ref_files <- list.files(path = "color_reference/", full.names = TRUE)
color_ref_files <-
  setNames(
    object = color_ref_files,
    nm = gsub(
      x = basename(color_ref_files),
      pattern = ".js",
      replacement = "",
      fixed = TRUE
    )
  )
color_reference_list <-
  lapply(
    X = setNames(names(color_ref_files), nm = names(color_ref_files)),
    FUN = function(source_name) {
      # Drop the variable naming from the beginning of the file and the brackets
      all_colors <-
        gsub(
          x = paste(readLines(color_ref_files[source_name]), collapse = " "),
          pattern = "^.*\\[ *\\{ *(.*) *\\} *\\]$",
          replacement = "\\1"
        )
      # Remove difficult to use characters
      all_colors_clean <-
        gsub(
          x = all_colors,
          pattern = "[^A-Za-z0-9 :'\"\\(\\),{}/]",
          replacement = ""
        )
      extract_color <-
        extract(
          data = tibble(
            color_def = strsplit(all_colors_clean, split = " *\\}, *\\{ *")[[1]]
          ),
          col = "color_def",
          into = c(source_name, "hex"),
          regex = "^['\"]?name['\"]?: *['\"]([A-Za-z0-9'/ \\(\\)]+)['\"] *, *['\"]?hex['\"]?: *['\"]#?([A-Fa-f0-9]{6})['\"] *$"
        ) |>
        verify(!is.na(hex)) |>
        mutate(hex = tolower(hex))
      extract_color
    }
  )
# Add the standard R colors to the list
color_reference_list$R <-
  tibble(
    R = grDevices::colors(),
    hex = tolower(rgb(t(col2rgb(grDevices::colors())), maxColorValue = 255))
  )

color_reference_name_hex_all <- Reduce(f = full_join, x = color_reference_list)

# Preference order for choosing alternate names
alt_name_order <- c("roygbiv", "basic", "html", "R", "pantone", "x11", "ntc")
if (
  length(missing_names <- setdiff(names(color_reference_list), alt_name_order))
) {
  stop(
    "alt_name_order needs additional names in it: ",
    paste(missing_names, collapse = ", ")
  )
}

color_reference_prep <-
  color_reference_name_hex_all |>
  # Ensure that priority order of the "name" is in the order of alt_name_order.
  select_at(.vars = c("hex", alt_name_order)) |>
  mutate(hex = gsub(x = hex, pattern = "#", replacement = "", fixed = TRUE)) |>
  group_by(hex) |>
  nest() |>
  mutate(
    # All available names
    name_alt = purrr::map(
      .x = data,
      .f = function(x) unique(na.omit(unlist(x)))
    ),
    # The preferred name
    name = purrr::map_chr(
      .x = name_alt,
      .f = function(x) x[1]
    ),
    # Which color sources have the name in them?
    containing_set = purrr::map(
      .x = data,
      .f = function(x)
        as.data.frame(lapply(X = x, FUN = function(y) any(!is.na(y))))
    )
  ) |>
  select(-data, hex, name, name_alt, containing_set) |>
  unnest(containing_set)

color_reference <-
  color_reference_prep |>
  bind_cols(
    as.data.frame(
      convertColor(
        t(col2rgb(paste0("#", color_reference_prep$hex))),
        from = "sRGB",
        to = "Lab",
        scale.in = 256
      )
    )
  ) |>
  select(hex, L, a, b, name, name_alt, everything())

usethis::use_data(color_reference, overwrite = TRUE, internal = TRUE)
