# ec_upscale

Aggregate ecosystem condition indicators, either to coarser spatial
scales, to to indices.

## Usage

``` r
ec_upscale(
  data,
  variable,
  weight,
  start_units,
  end_units,
  year = NULL,
  end_units_name = "name",
  n = 1000
)
```

## Arguments

- data:

  A data frame or tibble containing the input distributions and spatial
  grouping variables.

- variable:

  Column containing sampled values of the ecosystem condition indicator.
  These values represent the inferential uncertainty distribution for
  each `currentUnits` unit.

- weight:

  Column containing weights used when aggregating from `currentUnits` to
  `newUnits`, for example area, habitat area, or another relevant
  spatial weight.

- start_units:

  Column identifying the units from which one value is sampled in each
  Monte Carlo iteration. This is typically the current spatial scale, or
  the name of the indicator.

- end_units:

  Column identifying the final units to which the ecosystem condition
  indicator should be aggregated.

- year:

  Optional column identifying years or other temporal groups. If
  supplied, aggregation is performed separately for each combination of
  `year` and `start_units`.

- end_units_name:

  Name for the output column containing the names from `end_units`.
  Defaults to "name".

- n:

  Integer. Number of Monte Carlo samples to draw for each aggregated
  unit. Defaults to `1000`.

## Value

A tibble with one row per Monte Carlo sample for each aggregated spatial
unit, and optionally each year. The output contains:

- year:

  The year or temporal group, if `year` is supplied.

- area_name:

  The name or identifier of the aggregated `newUnits` spatial unit.

- sampled_mean:

  One Monte Carlo draw from the inferred distribution of the weighted
  mean ecosystem condition indicator for the aggregated unit.

## Details

`ec_upscale()` propagates inferential uncertainty in ecosystem condition
indicators into new probaility distributions for a high order. The
aggregation is from `start_units` to `end_units`. The function is
typically used to aggregate indicators from fine to coarser spatial
scales, or to aggregate different indicators to indices. The function
uses using Monte Carlo sampling. For each `start_unit` (fine spatial
scale unit, or indicator), and optionally for each `year`, the function
repeatedly samples one value from the distribution of each `start_unit`
and computes a weighted mean across those sampled values.

The input `variable` is assumed to represent a distribution of plausible
values for the true ecosystem condition indicator value of each
`start_unit` unit. The resulting `sampled_mean` values therefore
represent an inferential uncertainty distribution for the aggregated
value at the `end_units` level, rather than a descriptive distribution
of observed values. Point estimates and summary statistics, such as
means, medians, credible intervals, or quantiles, should be computed
from the returned distribution after aggregation.

For each `start_units` group, the function performs the following steps
`n` times:

1.  Sample one value from each `start_units` group.

2.  Compute the weighted mean of the sampled values using `weight`.

3.  Store the resulting weighted mean as one draw from the aggregated
    uncertainty distribution.

The function is designed for cases where uncertainty is represented as a
distribution of possible true values for each start unit. The output
should therefore be interpreted as an inferential uncertainty
distribution for each end unit.

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
library(stats)
set.seed(159)
dat <- data.frame(
  myVariable = c(rnorm(100, .4, .1), rnorm(100, .6, .1)),
  myWeight = rep(c(1, 2), each=100),
  start_units = rep(c("A", "B"), each=100),
  end_units = "A and B",
  year = 2026
  )

out <- ec_upscale(
   data = dat,
   variable = myVariable,
   weight = myWeight,
   start_units = start_units,
   end_units = end_units,
   year = year,
   n = 10
 )
out
#> # A tibble: 10 × 3
#>     year name    sampled_mean
#>    <dbl> <chr>          <dbl>
#>  1  2026 A and B        0.383
#>  2  2026 A and B        0.601
#>  3  2026 A and B        0.557
#>  4  2026 A and B        0.590
#>  5  2026 A and B        0.672
#>  6  2026 A and B        0.519
#>  7  2026 A and B        0.396
#>  8  2026 A and B        0.656
#>  9  2026 A and B        0.614
#> 10  2026 A and B        0.571

out |>
  summarise(mean = (mean(sampled_mean)))
#> # A tibble: 1 × 1
#>    mean
#>   <dbl>
#> 1 0.556
```
