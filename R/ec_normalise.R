#' ec_normalise
#'
#' Normalise a numeric vector to an ecological condition indicator
#'
#' Normalises (rescales) a numeric vector to values between 0 and 1 using reference values.
#' The function supports linear increasing, linear decreasing, two-sided, piecewise linear
#' normalisation, exponential and sigmoid functions.
#'
#' @param variable Numeric vector to be normalised.
#' @param x0 Numeric. Reference value corresponding to indicator value 0.
#'   Can be a single value or a vector with the same length as `variable`.
#'   Defaults to 0.
#' @param x60 Numeric or `NULL`. Optional reference value corresponding to
#'   indicator value 0.6. Can be a single value or a vector with the same length
#'   as `variable`. If supplied, and `fun = "linear"`, piecewise linear normalisation is used.
#'   x60 can also be combined with `fun = "sigmoid"`.
#' @param x100 Numeric. Reference value corresponding to indicator value 1.
#'   Can be a single value or a vector with the same length as `variable`.
#' @param x60h Numeric or `NULL`. Currently unused/reserved for future support
#'   for two-sided normalisation with an upper x60 reference value.
#' @param x0h Numeric or `NULL`. Optional high-end reference value corresponding
#'   to indicator value 0 in two-sided normalisation. Can be a single value or a
#'   vector with the same length as `variable`.
#' @param fun Character. Transformation function applied after normalisation.
#'   One of `"linear"` (no transformation), `"sigmoid"`, `"exponential convex"`, or
#'   `"exponential concave"`. Defaults to `"linear"`.
#' @param convex_exponent Numeric. Exponent used when
#'   `fun = "exponential convex"`. Defaults to 0.5.
#' @param concave_exponent Numeric. Exponent used when
#'   `fun = "exponential concave"`. Defaults to 2.
#'
#' @details
#' All reference parameters (`x0`, `x60`, `x100`, `x60h`, and `x0h`) may be
#' supplied either as single values or as vectors with the same length as
#' `variable`. If vector reference values are used, the relationship between
#' `x0` and `x100` must be consistent for all observations; that is, all
#' observations must either have `x0 < x100` or all must have `x0 > x100`.
#'
#' Values outside the reference range are truncated to the interval `[0, 1]`.
#'
#' Two-sided normalisation with defined `x60` values is currently not supported.
#' Exponential transformations are currently not supported when `x60` is used.
#'
#' @return A numeric vector with values between 0 and 1.
#'
#' @import rlang
#' @export
#'
#' @examples
#' x <- c(0, 2, 4, 6, 8, 10)
#'
#' ec_normalise(
#'   variable = x,
#'   x0 = 0,
#'   x100 = 10
#' )
#'
#' ec_normalise(
#'   variable = x,
#'   x0 = 10,
#'   x100 = 0
#' )
#'
#' ec_normalise(
#'   variable = x,
#'   x0 = 0,
#'   x60 = 5,
#'   x100 = 10
#' )
#'
#' ec_normalise(
#'   variable = x,
#'   x0 = 0,
#'   x100 = 5,
#'   x0h = 10
#' )
#'
#' ec_normalise(
#'   variable = x,
#'   x0 = rep(0, length(x)),
#'   x100 = seq(5, 10, length.out = length(x))
#' )
ec_normalise <- function(
  variable = NULL,
  x0 = 0,
  x60 = NULL,
  x100 = NULL,
  x60h = NULL,
  x0h = NULL,
  fun = "linear",
  convex_exponent = 0.5,
  concave_exponent = 2
) {
  if (!is_empty(x60) & !is_empty(x0h)) {
    stop(
      "Two-sided normalisation with defined x60 values are not yet supported."
    )
  }

  if (
    !is_empty(x60) &
      fun %in% c("exponential convex", "exponential concave")
  ) {
    stop(
      "x60 anchoring is not supported with exponential a transformation function"
    )
  }

  n <- length(variable)

  expand_to_n <- function(x, n, name) {
    if (is.null(x)) {
      return(rep(NA_real_, n))
    }
    if (length(x) == 1) {
      return(rep(x, n))
    }
    if (length(x) == n) {
      return(x)
    }
    stop(name, " must have length 1 or length(variable).")
  }

  x0 <- expand_to_n(x0, n, "x0")
  x60 <- expand_to_n(x60, n, "x60")
  x100 <- expand_to_n(x100, n, "x100")
  x60h <- expand_to_n(x60h, n, "x60h")
  x0h <- expand_to_n(x0h, n, "x0h")

  has_x60 <- !all(is.na(x60))
  has_x0h <- !all(is.na(x0h))

  increasing_vec <- x0 < x100

  if (!all(increasing_vec) && !all(!increasing_vec)) {
    stop("x0 and x100 must have the same direction for all observations.")
  }

  increasing <- all(increasing_vec)

  if (!increasing & has_x0h) {
    stop(
      "You have defined a function where both very low and very high variable values give high indicator values. This situation is not supported by this function, and probably it is also not what you want. "
    )
  }

  mode <- NULL

  if (!has_x60 && !has_x0h && increasing) {
    mode <- "linear_inc"
  }

  if (!has_x60 && !has_x0h && !increasing) {
    mode <- "linear_dec"
  }

  if (!has_x60 && has_x0h) {
    mode <- "two-sided"
  }

  if (has_x60 && increasing) {
    mode <- "piece_wise_lin_inc"
  }

  if (has_x60 && !increasing) {
    mode <- "piece_wise_lin_dec"
  }

  "%!in%" <- Negate("%in%")
  if (
    fun %!in%
      c("linear", "sigmoid", "exponential convex", "exponential concave")
  ) {
    stop("Unknown transformation function")
  }

  norm_lin_inc <- function() {
    (variable - x0) / (x100 - x0)
  }

  norm_lin_dec <- function() {
    (x0 - variable) / (x0 - x100)
  }

  norm_two_sided_linear <- function() {
    ifelse(
      variable < x100,
      (variable - x0) / (x100 - x0),
      ((variable - x100) / (x0h - x100)) * (-1) + 1
    )
  }

  norm_pw_lin_inc <- function() {
    ifelse(
      variable < x60,
      ((variable - x0) / (x60 - x0)) * 0.6,
      ((variable - x60) / (x100 - x60)) * (1 - 0.6) + 0.6
    )
  }

  norm_pw_lin_dec <- function() {
    ifelse(
      variable < x60,
      ((variable - x0) / (x60 - x0)) * 0.6,
      ((variable - x60) / (x100 - x60)) * (1 - 0.6) + 0.6
    )
  }

  trunc <- function(x) {
    pmin(pmax(x, 0), 1)
  }

  if (mode == "linear_inc") {
    indicator <- norm_lin_inc()
  }
  if (mode == "linear_dec") {
    indicator <- norm_lin_dec()
  }
  if (mode == "two-sided") {
    indicator <- norm_two_sided_linear()
  }
  if (mode == "piece_wise_lin_inc") {
    indicator <- norm_pw_lin_inc()
  }
  if (mode == "piece_wise_lin_dec") {
    indicator <- norm_pw_lin_dec()
  }

  indicator <- trunc(indicator)

  if (fun == "sigmoid") {
    indicator <- 100.68 * (1 - exp(-5 * indicator^2.5)) / 100
    indicator <- pmin(pmax(indicator, 0), 1)
  }
  if (fun == "exponential convex") {
    indicator <- indicator^convex_exponent
  }
  if (fun == "exponential concave") {
    indicator <- indicator^concave_exponent
  }

  return(indicator)
}
