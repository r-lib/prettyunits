library(tidyverse)
library(assertr)

color_ref_files <- list.files(path="color_reference/", full.names=TRUE)
color_ref_files <-
  setNames(
    object=color_ref_files,
    nm=
      gsub(
        x=basename(color_ref_files),
        pattern=".js",
        replacement="",
        fixed=TRUE
      )
  )
color_reference_list <-
  lapply(
    X=color_ref_files,
    FUN=function(x) {
      # Drop the variable naming from the beginning of the file and the brackets
      all_colors <-
        gsub(
          x=paste(readLines(x), collapse=" "),
          pattern="^.*\\[ *\\{ *(.*) *\\} *\\]$",
          replacement="\\1"
        )
      # Remove difficult to use characters
      all_colors_clean <-
        gsub(
          x=all_colors,
          pattern="[^A-Za-z0-9 :'\"\\(\\),{}]",
          replacement=""
        )
      extract_color <-
        extract(
          data=tibble(
            color_def=strsplit(all_colors_clean, split=" *\\}, *\\{ *")[[1]]
          ),
          col="color_def",
          into=c("name", "hex"),
          regex="^['\"]?name['\"]?: *['\"]([A-Za-z0-9'/ \\(\\)]+)['\"] *, *['\"]?hex['\"]?: *['\"]#?([A-Fa-f0-9]{6})['\"] *$"
        ) %>%
        verify(!is.na(hex))
      add_lab <-
        bind_cols(
          extract_color,
          as.data.frame(
            convertColor(
              t(col2rgb(paste0("#", extract_color$hex))),
              from="sRGB", to="Lab",
              scale.in=256
            )
          )
        )
      add_lab
    }
  )

color_reference <-
  bind_rows(
    lapply(
      X=names(color_reference_list),
      FUN=function(x) {
        ret <- color_reference_list[[x]]
        ret[[x]] <- TRUE
        ret
      }
    )
  ) %>%
  mutate(
    name=tolower(name),
    hex=tolower(hex)
  ) %>%
  group_by(name, hex, L, a, b) %>%
  summarize_all(.funs=function(x) any(x %in% TRUE)) %>%
  # Deduplicate names for a specific hex
  group_by(hex) %>%
  mutate_at(.vars=names(color_reference_list), .funs=any) %>%
  mutate(
    count=n(),
    is_british_grey=grepl(x=name, pattern="grey"),
    name_british=
      case_when(
        name == "slate gray"~"slate grey",
        count == 2 & sum(!is_british_grey) == 1 & sum(is_british_grey) == 1 & !is_british_grey~name,
        count == 2 & sum(!is_british_grey) == 1 & sum(is_british_grey) == 1 & is_british_grey~"DROP THIS COLOR"
      )
  ) %>%
  select(-is_british_grey) %>%
  filter(!name_british %in% "DROP THIS COLOR") %>%
  # Remove names that are missing a space when a name with a space exists
  mutate(
    count=n(),
    one_space_different=
      max(nchar(name)) == (min(nchar(name)) + 1) &
      length(unique(gsub(x=name, pattern=" ", replacement=""))) == 1,
  ) %>%
  # Keep the name with the space
  filter(
    !one_space_different |
      (one_space_different & count == 2 & nchar(name) == max(nchar(name)))
  ) %>%
  select(-one_space_different) %>%
  # Arbitrary choices selected to be more descriptive in my opinion
  mutate(
    count=n(),
    name_alt=
      case_when(
        hex == "000080" & name == "navy"~"DROP THIS COLOR",
        hex == "000080" & name == "navy blue"~"navy",
        hex == "00ff00" & name == "green"~"DROP THIS COLOR",
        hex == "00ff00" & name == "lime"~"green",
        hex == "00ffff" & name %in% c("aqua", "cyan  aqua")~"DROP THIS COLOR",
        hex == "00ffff" & name == "cyan"~"aqua",
        hex == "4b0082" & name == "pigment indigo"~"DROP THIS COLOR",
        hex == "4b0082" & name == "indigo"~"pigment indigo",
        hex == "708090" & name %in% c("slategray", "slategrey")~"DROP THIS COLOR",
        hex == "c71585" & name == "mediumvioletred"~"DROP THIS COLOR",
        hex == "c71585" & name == "red violet"~"mediumvioletred",
        hex == "cd5c5c" & name == "indianred"~"DROP THIS COLOR",
        hex == "cd5c5c" & name == "chestnut rose"~"indianred",
        hex == "d2691e" & name == "hot cinnamon"~"DROP THIS COLOR",
        hex == "d2691e" & name == "chocolate"~"hot cinnamon",
        hex == "daa520" & name == "goldenrod"~"DROP THIS COLOR",
        hex == "daa520" & name == "golden grass"~"goldenrod",
        hex == "e0ffff" & name == "lightcyan"~"DROP THIS COLOR",
        hex == "e0ffff" & name == "baby blue"~"lightcyan",
        hex == "ee82ee" & name == "lavender magenta"~"DROP THIS COLOR",
        hex == "ee82ee" & name == "violet"~"",
        hex == "fdd7e4" & name == "piggy pink"~"DROP THIS COLOR",
        hex == "fdd7e4" & name == "pig pink"~"piggy pink",
        hex == "fdfc74" & name == "laser lemon"~"DROP THIS COLOR",
        hex == "fdfc74" & name == "unmellow yellow"~"laser lemon",
        hex == "ff00ff" & name %in% c("fuchsia", "magenta  fuchsia")~"DROP THIS COLOR",
        hex == "ff00ff" & name == "magenta"~"fuchsia",
        hex == "ff1dce" & name == "purple pizzazz"~"DROP THIS COLOR",
        hex == "ff1dce" & name == "hot magenta"~"purple pizzazz",
        hex == "ffa500" & name == "web orange"~"DROP THIS COLOR",
        hex == "ffa500" & name == "orange"~"web orange",
        hex == "fff5ee" & name == "seashell peach"~"DROP THIS COLOR",
        hex == "fff5ee" & name == "seashell"~"seashell peach",
        hex == "ffff99" & name == "pale canary"~"DROP THIS COLOR",
        hex == "ffff99" & name == "canary"~"pale canary"
      )
  ) %>%
  filter(!(name_alt %in% "DROP THIS COLOR")) %>%
  mutate(count=n())

# Verify that there is only one name per hex
if (nrow(color_reference %>% filter(count > 1)) != 0) {
  stop("Update so that hex values are unique per name")
}
# Note that the names are not necessarily unique (often because pantone defines
# a slightly different color than others for the same name)

color_reference <-
  color_reference %>%
  select(-count) %>%
  select(name, name_british, name_alt, everything())

usethis::use_data(color_reference, overwrite=TRUE)
