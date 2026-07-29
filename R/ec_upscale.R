#' ec_upscale
#'
#' Aggregate ecosystem condition indicators, either  to coarser spatial scales, to to indices.
#'
#' `ec_upscale()` propagates inferential uncertainty in ecosystem condition
#' indicators into new probaility distributions for a high order. The aggregation
#' is from `start_units` to `end_units`. The function is typically used to
#' aggregate indicators from fine to coarser spatial scales, or to aggregate different indicators to indices.
#' The function uses using Monte Carlo sampling. For each `start_unit` (fine spatial scale unit, or indicator),
#' and optionally for each `year`, the function repeatedly samples one value from the distribution of
#' each `start_unit` and computes a weighted mean across those sampled values.
#'
#' The input `variable` is assumed to represent a distribution of plausible
#' values for the true ecosystem condition indicator value of each
#' `start_unit` unit. The resulting `sampled_value` therefore represent
#' an inferential uncertainty distribution for the aggregated value at the
#' `end_units` level, rather than a descriptive distribution of observed values.
#' Point estimates and summary statistics, such as means, medians, credible
#' intervals, or quantiles, should be computed from the returned distribution
#' after aggregation.
#' 
#' The aggregation, or upscaling, can be done using weighted means, 
#' weighted sums, or plain sums.
#'
#' @param data A data frame or tibble containing the input distributions and
#'   spatial grouping variables.
#' @param variable Column containing sampled values of the ecosystem condition
#'   indicator. These values represent the inferential uncertainty distribution
#'   for each `currentUnits` unit.
#' @param weight Column containing weights used when aggregating from
#'   `currentUnits` to `newUnits`, for example area, habitat area, or another
#'   relevant spatial weight.
#' @param start_units Column identifying the units from which one
#'   value is sampled in each Monte Carlo iteration. This is typically the current
#'   spatial scale, or the name of the indicator.
#' @param end_units Column identifying the final units to which the
#'   ecosystem condition indicator should be aggregated.
#' @param year Optional column identifying years or other temporal groups. If
#'   supplied, aggregation is performed separately for each combination of
#'   `year` and `end_units`. If omitted,
#'   all observations are pooled before upscaling.
#' @param end_units_name Name for the output column containing the names from `end_units`.
#'   Defaults to "name".
#' @param n Integer. Number of Monte Carlo samples to draw for each aggregated
#'   unit. Defaults to `1000`.
#' @param aggregation Character. Type of aggregation method. One of `weighted_mean`,
#'   `weighted_sum`, and `sum`. Defaults to `weighted_mean`.
#'
#' @return A tibble with one row per Monte Carlo sample for each aggregated
#'   spatial unit, and optionally each year. The output contains:
#'   \describe{
#'     \item{year}{The year or temporal group, if `year` is supplied.}
#'     \item{area_name}{The name or identifier of the aggregated `newUnits`
#'       spatial unit.}
#'     \item{sampled_value}{One Monte Carlo draw from the inferred distribution
#'       of the ecosystem condition indicator for the aggregated
#'       unit.}
#'   }
#'
#' @details
#' For each `start_units` group, the function performs the following steps `n`
#' times:
#'
#' \enumerate{
#'   \item Sample one value from each `start_units` group.
#'   \item Compute the weighted mean or sum of the sampled values using `weight`.
#'   \item Store the resulting value (weighted mean, weighted sum, or sum) 
#'     as one draw from the aggregated uncertainty distribution.
#' }
#'
#' The function is designed for cases where uncertainty is represented as a
#' distribution of possible true values for each start unit. The
#' output should therefore be interpreted as an inferential uncertainty
#' distribution for each end unit.
#'
#' @examples
#' library(dplyr)
#' library(stats)
#' set.seed(159)
#' dat <- data.frame(
#'   myVariable = c(rnorm(100, .4, .1), rnorm(100, .6, .1)),
#'   myWeight = rep(c(1, 2), each=100),
#'   start_units = rep(c("A", "B"), each=100),
#'   end_units = "A and B",
#'   year = 2026
#'   )
#'
#' out <- ec_upscale(
#'    data = dat,
#'    variable = myVariable,
#'    weight = myWeight,
#'    start_units = start_units,
#'    end_units = end_units,
#'    year = year,
#'    n = 10
#'  )
#' out
#'
#' out |>
#'   summarise(mean = (mean(sampled_value)))
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
  start_units,
  end_units,
  year = NULL,
  end_units_name = "name",
  n = 1000,
  aggregation = c("weighted_mean", "weighted_sum", "sum")
) {
  aggregation <- match.arg(aggregation)
  variable <- rlang::ensym(variable)
  weight <- rlang::ensym(weight)
  start_units <- rlang::ensym(start_units)
  end_units <- rlang::ensym(end_units)
  
  year <- rlang::enquo(year)
  year_missing <- rlang::quo_is_null(year)

  group_vars <- if (year_missing) {
    rlang::quos(!!end_units)
  } else {
    rlang::quos(!!year, !!end_units)
  }

  one_sample <- function(df) {
    sampled <- df |>
      dplyr::group_by(!!start_units) |>
      dplyr::slice_sample(n = 1) |>
      dplyr::ungroup()
    
    values <- dplyr::pull(sampled, !!variable)
    weights <- dplyr::pull(sampled, !!weight)

    switch(
      aggregation,
      weighted_mean = stats::weighted.mean(
        values,
        weights,
        na.rm = TRUE
      ),
      weighted_sum = sum(
        values * weights,
        na.rm = TRUE
      ),
      sum = sum(
        values,
        na.rm = TRUE
      )
    )
  }

  data |>
    group_by(!!!group_vars) |>
    dplyr::group_modify(\(df, ...) {
      tibble::tibble(
        value = replicate(n, one_sample(df))
      )
    }) |>
    dplyr::ungroup() |>
    rename(!!end_units_name := end_units, sampled_value = value)
}
