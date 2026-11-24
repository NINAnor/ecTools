x <- seq(0, 1000, by = 2)

ind <- ec_normalise(
  variable = x,
  x0 = 100,
  x100 = 900,
  x60 = 200
)

ec_norm_plot(
  variable = x,
  indicator = ind,
  lan = "norsk"
)

ind <- ec_normalise(
  variable = x,
  x0 = 50,
  x100 = rnorm(n = length(x), 400, 50),
  x0h = 900,
  fun = "sigmoid"
)

ec_norm_plot(
  variable = x,
  indicator = ind
)

# Power transformation
ind <- ec_normalise(
  variable = x,
  x0 = 100,
  x100 = 900,
  fun = "power",
  power_exponent = 0.1
)

ec_norm_plot(x, ind)

# Quadratic transformation
ind <- ec_normalise(
  variable = x,
  x0 = 100,
  x100 = 900,
  fun = "quadratic",
  quadratic_curvature = 1
)

ec_norm_plot(x, ind)
