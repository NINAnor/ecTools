#' ec_norm_plot
#'
#' Plot normalised ecological indicator values against the raw variable values
#'
#' Creates a scatter plot comparing raw variable values and corresponding
#' normalised indicator values produced by [ec_normalise_dev()].
#'
#' The plot is intended as a simple diagnostic and visualisation tool for
#' evaluating ecological normalisation functions.
#'
#' @param variable Numeric vector of raw variable values.
#' @param indicator Numeric vector of normalised indicator values, typically
#'   produced by [ec_normalise_dev()].
#' @param lan Character. Plot language. One of `"english"` or `"norsk"`.
#'   Defaults to `"english"`.
#'
#' @details
#' Points are coloured according to the indicator value using a red-to-green
#' colour gradient.
#'
#' The function returns a `ggplot2` object and can therefore be further modified
#' using standard `ggplot2` syntax.
#'
#' @return A `ggplot2` object.
#'
#' @import ggplot2
#' @importFrom ggridges geom_density_ridges_gradient
#' @importFrom tibble tibble
#' @export
#'
#' @examples
#' x <- c(0, 2, 4, 6, 8, 10)
#'
#' ind <- ec_normalise_dev(
#'   variable = x,
#'   x0 = 0,
#'   x100 = 10
#' )
#'
#' ec_norm_plot(
#'   variable = x,
#'   indicator = ind
#' )
#'
#' ind_pw <- ec_normalise_dev(
#'   variable = x,
#'   x0 = 0,
#'   x60 = 5,
#'   x100 = 10
#' )
#'
#' ec_norm_plot(
#'   variable = x,
#'   indicator = ind_pw,
#'   lan = "norsk"
#' )

ec_norm_plot <- function(variable, indicator, lan = "english") {
  low <- "red"
  high <- "green"
  ridge <- ggridges::geom_density_ridges_gradient(scale = 3, size = .3)
  mySize <- 8
  myAlpha <- .7
  myShape <- 21
  if (lan == "english") {
    myYlab <- "Indicator values"
  }
  if (lan == "norsk") {
    myYlab <- "Indikatorverdier"
  }
  if (lan == "english") {
    myXlab <- "Variable values"
  }
  if (lan == "norsk") {
    myXlab <- "Variabelverdier"
  }

  dat <- tibble(indicator, variable)

  ggOut <- ggplot(
    dat,
    aes(x = variable, y = indicator, fill = indicator)
  ) +
    geom_point(
      stroke = NA,
      size = mySize,
      alpha = myAlpha,
      shape = myShape
    ) +
    ylab(myYlab) +
    xlab(myXlab) +
    scale_fill_gradient(low = low, high = high) +
    scale_x_continuous(expand = expansion(mult = .2)) +
    scale_y_continuous(
      breaks = seq(0, 1, by = .2),
      expand = expansion(mult = .2)
    ) +
    guides(fill = "none") +
    theme_bw(base_size = 16)
  ggOut
}
