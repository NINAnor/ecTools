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
  concave_exponent = 2
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
  `"linear"` (no transformation), `"sigmoid"`, `"exponential convex"`,
  or `"exponential concave"`. Defaults to `"linear"`.

- convex_exponent:

  Numeric. Exponent used when `fun = "exponential convex"`. Defaults to
  0.5.

- concave_exponent:

  Numeric. Exponent used when `fun = "exponential concave"`. Defaults to
  2.

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

Values outside the reference range are truncated to the interval
`[0, 1]`.

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
```
