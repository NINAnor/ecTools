# ec_normalise

Normalise a numeric vector to an ecological condition indicator

## Usage

``` r
ec_normalise(
  variable = NULL,
  x0 = 0,
  x60 = NULL,
  x100 = NULL,
  x60h = NULL,
  x0h = NULL,
  fun = "linear",
  convex_exponent = 0.5,
  concave_exponent = 2,
  truncation = TRUE,
  power_exponent = 1,
  quadratic_curvature = 0
)
```

## Arguments

- variable:

  Numeric vector to be normalised.

- x0:

  Numeric. Reference value corresponding to indicator value 0. Can be a
  single value or a vector with the same length as `variable`. Defaults
  to 0.

- x60:

  Numeric or `NULL`. Optional reference value corresponding to indicator
  value 0.6. Can be a single value or a vector with the same length as
  `variable`. If supplied, and `fun = "linear"`, piecewise linear
  normalisation is used. x60 can also be combined with
  `fun = "sigmoid"`.

- x100:

  Numeric. Reference value corresponding to indicator value 1. Can be a
  single value or a vector with the same length as `variable`.

- x60h:

  Numeric or `NULL`. Currently unused/reserved for future support for
  two-sided normalisation with an upper x60 reference value.

- x0h:

  Numeric or `NULL`. Optional high-end reference value corresponding to
  indicator value 0 in two-sided normalisation. Can be a single value or
  a vector with the same length as `variable`.

- fun:

  Character. Transformation function applied after normalisation. One of
  `"linear"`, `"sigmoid"`, `"power"`, or `"quadratic"`. Defaults to
  `"linear"`.

- convex_exponent:

  **\[deprecated\]** Use `power_exponent` instead.

- concave_exponent:

  **\[deprecated\]** Use `power_exponent` instead.

- truncation:

  Logical. If `TRUE` (the default), normalised values are clamped to the
  interval `[0, 1]`. If `FALSE`, values outside the reference range are
  linearly extrapolated and may fall below 0 or above 1. Disabling
  truncation is only supported when `fun = "linear"`.

- power_exponent:

  Positive numeric scalar. Exponent used when `fun = "power"`. Values
  below 1 produce concave transformations, and values above 1 produce
  convex transformations. A value of 1 gives linear normalisation.

- quadratic_curvature:

  Numeric scalar between -1 and 1. Negative values produce convex
  transformations, positive values produce concave transformations, and
  0 gives linear normalisation.

## Value

A numeric vector with values between 0 and 1.

## Details

Normalises (rescales) a numeric vector to values between 0 and 1 using
reference values. The function supports linear increasing, linear
decreasing, two-sided, piecewise linear normalisation, exponential and
sigmoid functions.

All reference parameters (`x0`, `x60`, `x100`, `x60h`, and `x0h`) may be
supplied either as single values or as vectors with the same length as
`variable`. If vector reference values are used, the relationship
between `x0` and `x100` must be consistent for all observations; that
is, all observations must either have `x0 < x100` or all must have
`x0 > x100`.

By default, values outside the reference range are truncated to the
interval `[0, 1]`. Set `truncation = FALSE` to instead extrapolate the
linear mapping beyond the reference range, returning values below 0 or
above 1. This is only available when `fun = "linear"`, because the
non-linear transformations would otherwise produce `NaN` for negative
extrapolated values.

Two-sided normalisation with defined `x60` values is currently not
supported. Exponential transformations are currently not supported when
`x60` is used.

## Examples

``` r
x <- c(0, 2, 4, 6, 8, 10)

ec_normalise(
  variable = x,
  x0 = 0,
  x100 = 10
)
#> [1] 0.0 0.2 0.4 0.6 0.8 1.0

ec_normalise(
  variable = x,
  x0 = 10,
  x100 = 0
)
#> [1] 1.0 0.8 0.6 0.4 0.2 0.0

ec_normalise(
  variable = x,
  x0 = 0,
  x60 = 5,
  x100 = 10
)
#> [1] 0.00 0.24 0.48 0.68 0.84 1.00

ec_normalise(
  variable = x,
  x0 = 0,
  x100 = 5,
  x0h = 10
)
#> [1] 0.0 0.4 0.8 0.8 0.4 0.0

ec_normalise(
  variable = x,
  x0 = rep(0, length(x)),
  x100 = seq(5, 10, length.out = length(x))
)
#> [1] 0.0000000 0.3333333 0.5714286 0.7500000 0.8888889 1.0000000

ec_normalise(
  variable = c(-2, 0, 5, 10, 12),
  x0 = 0,
  x100 = 10,
  truncation = FALSE
)
#> [1] -0.2  0.0  0.5  1.0  1.2
# Concave power transformation
ec_normalise(
  variable = x,
  x0 = 0,
  x100 = 10,
  fun = "power",
  power_exponent = 0.5
)
#> [1] 0.0000000 0.4472136 0.6324555 0.7745967 0.8944272 1.0000000
# Convex quadratic transformation
ec_normalise(
  variable = x,
  x0 = 0,
  x100 = 10,
  fun = "quadratic",
  quadratic_curvature = -0.8
)
#> [1] 0.000 0.072 0.208 0.408 0.672 1.000

# Sigmoid transformation
ec_normalise(
  variable = x,
  x0 = 0,
  x100 = 10,
  fun = "sigmoid"
)
#> [1] 0.00000000 0.08614116 0.39977630 0.75710048 0.94926662 1.00000000
```
