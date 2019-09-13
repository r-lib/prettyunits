#' Color definition (like RGB) to a name
#'
#' @param color A scalar color that is usable as an input to `col2rgb()`
#'   (assumed to be in the sRGB color space).
#' @param color_set Should the returned color names come from a "simple" smaller
#'   set or a longer, more "complete" set?
#' @return A character string that is the closest named colors to the input
#'   color.  The output will have an attribute of alternate color names (named
#'   "alt").
#' @export
#' @importFrom grDevices col2rgb convertColor
# Maybe "importFrom spacesXYZ DeltaE" if we always want the (current) best color
# distance formula.
pretty_color <- function(color, color_set=c("simple", "complete")) {
  stopifnot(length(color) == 1)
  if (is.na(color)) {
    structure(NA_character_, alt=NA_character_)
  } else {
    color_set <- match.arg(color_set)
    if (is.factor(color)) color <- as.character(color)
    stopifnot(is.character(color))
    color_rgb <- col2rgb(color)
    color_lab <- convertColor(t(color_rgb), from="sRGB", to="Lab", scale.in=256)
    color_reference_set <-
      if (color_set == "simple") {
        color_reference[color_reference$basic | color_reference$roygbiv, ]
      } else {
        color_reference
      }
    dist <-
      if (requireNamespace("spacesXYZ")) {
        spacesXYZ::DeltaE(
          Lab1=color_lab,
          Lab2=as.matrix(color_reference_set[, c("L", "a", "b")])
        )
      } else {
        message("Install the spacesXYZ package for an improved color distance calculation.")
        # This is the same as Delta E 1976, but it's simple enough to implement
        # here
        sqrt(
          (color_lab[1] - color_reference_set$L)^2 +
            (color_lab[2] - color_reference_set$a)^2 +
            (color_lab[3] - color_reference_set$b)^2
        )
      }
    ret <- color_reference_set$name[dist == min(dist)][1]
    attr(ret, "alt") <- color_reference_set$name_alt[dist == min(dist)][[1]]
    ret
  }
}

#' @rdname pretty_color
#' @export
pretty_colour <- pretty_color

#' Color names, hexadecimal, and CIE Lab colorspace representations
#' 
#' \describe{
#'   \item{hex}{hexadecimal color representation (without the # at the beginning)}
#'   \item{L,a,b}{CIE Lab colorspace representation of `hex`}
#'   \item{name}{Preferred human-readable name of the color}
#'   \item{name_alt}{All available human-readable names of the color}
#'   \item{roygbiv,basic,html,R,pantone,x11,ntc}{Source dataset containing the color}
#' }
#' @source {https://github.com/colorjs/color-namer} and R `colors()`
"color_reference"