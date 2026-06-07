test_that("linear increasing maps reference values correctly", {
  x <- c(0, 5, 10)
  expect_equal(ec_normalise(variable = x, x0 = 0, x100 = 10), c(0, 0.5, 1))
})

test_that("linear decreasing maps reference values correctly", {
  x <- c(0, 5, 10)
  expect_equal(ec_normalise(variable = x, x0 = 10, x100 = 0), c(1, 0.5, 0))
})

test_that("piecewise linear anchors x60 at 0.6", {
  x <- c(0, 5, 10)
  expect_equal(
    ec_normalise(variable = x, x0 = 0, x60 = 5, x100 = 10),
    c(0, 0.6, 1)
  )
})

test_that("two-sided normalisation peaks at x100", {
  x <- c(0, 5, 10)
  expect_equal(
    ec_normalise(variable = x, x0 = 0, x100 = 5, x0h = 10),
    c(0, 1, 0)
  )
})

test_that("vector reference values are recycled correctly", {
  x <- c(2, 5)
  res <- ec_normalise(
    variable = x,
    x0 = c(0, 0),
    x100 = c(10, 5)
  )
  expect_equal(res, c(0.2, 1))
})

test_that("truncation = TRUE (default) clamps values to [0, 1]", {
  x <- c(-5, 0, 5, 10, 15)
  expect_equal(
    ec_normalise(variable = x, x0 = 0, x100 = 10),
    c(0, 0, 0.5, 1, 1)
  )
})

test_that("truncation = FALSE extrapolates a linear increasing mapping", {
  x <- c(-5, 0, 5, 10, 15)
  expect_equal(
    ec_normalise(variable = x, x0 = 0, x100 = 10, truncation = FALSE),
    c(-0.5, 0, 0.5, 1, 1.5)
  )
})

test_that("truncation = FALSE extrapolates a linear decreasing mapping", {
  x <- c(-5, 0, 5, 10, 15)
  expect_equal(
    ec_normalise(variable = x, x0 = 10, x100 = 0, truncation = FALSE),
    c(1.5, 1, 0.5, 0, -0.5)
  )
})

test_that("truncation = FALSE extrapolates piecewise linear segments", {
  x <- c(-5, 15)
  res <- ec_normalise(
    variable = x,
    x0 = 0,
    x60 = 5,
    x100 = 10,
    truncation = FALSE
  )
  # lower segment slope: 0.6 / 5 per unit; upper segment slope: 0.4 / 5 per unit
  expect_equal(res, c(-0.6, 1.4))
})

test_that("truncation = FALSE extrapolates the two-sided mapping", {
  x <- c(-5, 15)
  res <- ec_normalise(
    variable = x,
    x0 = 0,
    x100 = 5,
    x0h = 10,
    truncation = FALSE
  )
  expect_equal(res, c(-1, -1))
})

test_that("truncation = FALSE works with vector reference values", {
  x <- c(-2, 10)
  res <- ec_normalise(
    variable = x,
    x0 = c(0, 0),
    x100 = c(10, 5),
    truncation = FALSE
  )
  expect_equal(res, c(-0.2, 2))
})

test_that("truncation = FALSE errors with non-linear transformations", {
  x <- c(0, 5, 10)
  expect_error(
    ec_normalise(variable = x, x0 = 0, x100 = 10, fun = "sigmoid", truncation = FALSE),
    'only supported with fun = "linear"'
  )
  expect_error(
    ec_normalise(
      variable = x,
      x0 = 0,
      x100 = 10,
      fun = "exponential convex",
      truncation = FALSE
    ),
    'only supported with fun = "linear"'
  )
})

test_that("non-numeric variable raises an error", {
  expect_error(
    ec_normalise(variable = c("a", "b", "c"), x0 = 0, x100 = 10),
    "must be a numeric vector"
  )
})

test_that("non-numeric reference values raise an error", {
  x <- c(0, 5, 10)
  expect_error(
    ec_normalise(variable = x, x0 = "0", x100 = 10),
    "`x0` must be numeric"
  )
  expect_error(
    ec_normalise(variable = x, x0 = 0, x100 = "10"),
    "`x100` must be numeric"
  )
  expect_error(
    ec_normalise(variable = x, x0 = 0, x60 = "5", x100 = 10),
    "`x60` must be numeric"
  )
})

test_that("invalid truncation values raise an error", {
  x <- c(0, 5, 10)
  expect_error(
    ec_normalise(variable = x, x0 = 0, x100 = 10, truncation = "yes"),
    "must be either TRUE or FALSE"
  )
  expect_error(
    ec_normalise(variable = x, x0 = 0, x100 = 10, truncation = NA),
    "must be either TRUE or FALSE"
  )
})
