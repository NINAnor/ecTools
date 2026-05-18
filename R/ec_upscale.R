#' ec_upscale
#'
#' Aggregate ecosystem condition indicators to coarser spatial scales
#'
#' `ec_upscale()` propagates inferential uncertainty in ecosystem condition
#' indicators from finer spatial units to coarser spatial units using Monte Carlo
#' sampling. For each coarse spatial unit, and optionally for each year, the
#' function repeatedly samples one value from the distribution of each finer
#' spatial unit and computes a weighted mean across those sampled values.
#'
#' The input `variable` is assumed to represent a distribution of plausible
#' values for the true ecosystem condition indicator value of each
#' `currentUnits` unit. The resulting `sampled_mean` values therefore represent
#' an inferential uncertainty distribution for the aggregated value at the
#' `newUnits` level, rather than a descriptive distribution of observed values.
#' Point estimates and summary statistics, such as means, medians, credible
#' intervals, or quantiles, should be computed from the returned distribution
#' after aggregation.
#'
#' @param data A data frame or tibble containing the input distributions and
#'   spatial grouping variables.
#' @param variable Column containing sampled values of the ecosystem condition
#'   indicator. These values represent the inferential uncertainty distribution
#'   for each `currentUnits` unit.
#' @param weight Column containing weights used when aggregating from
#'   `currentUnits` to `newUnits`, for example area, habitat area, or another
#'   relevant spatial weight.
#' @param currentUnits Column identifying the finer spatial units from which one
#'   value is sampled in each Monte Carlo iteration.
#' @param newUnits Column identifying the coarser spatial units to which the
#'   ecosystem condition indicator should be aggregated.
#' @param year Optional column identifying years or other temporal groups. If
#'   supplied, aggregation is performed separately for each combination of
#'   `year` and `newUnits`.
#' @param n Integer. Number of Monte Carlo samples to draw for each aggregated
#'   unit. Defaults to `1000`.
#'
#' @return A tibble with one row per Monte Carlo sample for each aggregated
#'   spatial unit, and optionally each year. The output contains:
#'   \describe{
#'     \item{year}{The year or temporal group, if `year` is supplied.}
#'     \item{area_name}{The name or identifier of the aggregated `newUnits`
#'       spatial unit.}
#'     \item{sampled_mean}{One Monte Carlo draw from the inferred distribution
#'       of the weighted mean ecosystem condition indicator for the aggregated
#'       unit.}
#'   }
#'
#' @details
#' For each `newUnits` group, the function performs the following steps `n`
#' times:
#'
#' \enumerate{
#'   \item Sample one value from each `currentUnits` group.
#'   \item Compute the weighted mean of the sampled values using `weight`.
#'   \item Store the resulting weighted mean as one draw from the aggregated
#'     uncertainty distribution.
#' }
#'
#' The function is designed for cases where uncertainty is represented as a
#' distribution of possible true values for each fine-scale spatial unit. The
#' output should therefore be interpreted as an inferential uncertainty
#' distribution for each coarser spatial unit.
#'
#' @examples
#' library(dplyr)
#' library(stats)
#' set.seed(159)
#' dat <- data.frame(
#'   myVariable = c(rnorm(100, .4, .1), rnorm(100, .6, .1)),
#'   myWeight = rep(c(1, 2), each=100),
#'   currentUnits = rep(c("A", "B"), each=100),
#'   newUnits = "A and B",
#'   year = 2026
#'   )
#'
#' out <- ec_upscale(
#'    data = dat,
#'    variable = myVariable,
#'    weight = myWeight,
#'    currentUnits = currentUnits,
#'    newUnits = newUnits,
#'    year = year,
#'    n = 10
#'  )
#' out
#'
#' out |>
#'   summarise(mean = (mean(sampled_mean)))
#'
#' @importFrom dplyr group_by group_modify slice_sample ungroup summarise rename
#' @importFrom rlang ensym
#' @importFrom tibble tibble
#' @importFrom stats weighted.mean
#'
#' @export

ec_upscale <- function(
  data,
  variable,
  weight,
  currentUnits,
  newUnits,
  year = NULL,
  n = 1000
) {
  variable <- rlang::ensym(variable)
  weight <- rlang::ensym(weight)
  currentUnits <- rlang::ensym(currentUnits)
  newUnits <- rlang::ensym(newUnits)
  year <- rlang::ensym(year)

  one_sample <- function(df) {
    df |>
      dplyr::group_by(!!currentUnits) |>
      dplyr::slice_sample(n = 1) |>
      dplyr::ungroup() |>
      dplyr::summarise(
        mean = weighted.mean(!!variable, !!weight, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::pull(mean)
  }

  data |>
    group_by(!!year, !!newUnits) |>
    dplyr::group_modify(\(df, ...) {
      tibble::tibble(
        mean = replicate(n, one_sample(df))
      )
    }) |>
    dplyr::ungroup() |>
    rename(area_name = !!newUnits, sampled_mean = mean)
}
