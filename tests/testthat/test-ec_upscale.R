test_that("ec_upscale calculates weighted means", {
  dat <- data.frame(
    value = c(2, 2, 4, 4),
    weight = c(1, 1, 3, 3),
    start_unit = c("A", "A", "B", "B"),
    end_unit = "all"
  )

  result <- ec_upscale(
    data = dat,
    variable = value,
    weight = weight,
    start_units = start_unit,
    end_units = end_unit,
    n = 3,
    aggregation = "weighted_mean"
  )

  expect_equal(
    result$sampled_value,
    rep((2 * 1 + 4 * 3) / (1 + 3), 3)
  )
})

test_that("ec_upscale calculates weighted sums", {
  dat <- data.frame(
    value = c(2, 2, 4, 4),
    weight = c(1, 1, 3, 3),
    start_unit = c("A", "A", "B", "B"),
    end_unit = "all"
  )

  result <- ec_upscale(
    data = dat,
    variable = value,
    weight = weight,
    start_units = start_unit,
    end_units = end_unit,
    n = 3,
    aggregation = "weighted_sum"
  )

  expect_equal(
    result$sampled_value,
    rep(2 * 1 + 4 * 3, 3)
  )
})

test_that("ec_upscale calculates unweighted sums", {
  dat <- data.frame(
    value = c(2, 2, 4, 4),
    weight = c(1, 1, 3, 3),
    start_unit = c("A", "A", "B", "B"),
    end_unit = "all"
  )

  result <- ec_upscale(
    data = dat,
    variable = value,
    weight = weight,
    start_units = start_unit,
    end_units = end_unit,
    n = 3,
    aggregation = "sum"
  )

  expect_equal(
    result$sampled_value,
    rep(2 + 4, 3)
  )
})

test_that("weighted_mean is the default aggregation", {
  dat <- data.frame(
    value = c(2, 4),
    weight = c(1, 3),
    start_unit = c("A", "B"),
    end_unit = "all"
  )

  default_result <- ec_upscale(
    data = dat,
    variable = value,
    weight = weight,
    start_units = start_unit,
    end_units = end_unit,
    n = 1
  )

  explicit_result <- ec_upscale(
    data = dat,
    variable = value,
    weight = weight,
    start_units = start_unit,
    end_units = end_unit,
    n = 1,
    aggregation = "weighted_mean"
  )

  expect_equal(default_result, explicit_result)
})

test_that("ec_upscale rejects unknown aggregation methods", {
  dat <- data.frame(
    value = c(2, 4),
    weight = c(1, 3),
    start_unit = c("A", "B"),
    end_unit = "all"
  )

  expect_error(
    ec_upscale(
      data = dat,
      variable = value,
      weight = weight,
      start_units = start_unit,
      end_units = end_unit,
      aggregation = "median"
    ),
    "'arg' should be one of"
  )
})

test_that("ec_upscale works without year", {

  dat <- tibble::tibble(
    value = c(1, 1, 2, 2),
    weight = 1,
    start = c("A", "A", "B", "B"),
    region = "Norway"
  )

  result <- ec_upscale(
    data = dat,
    variable = value,
    weight = weight,
    start_units = start,
    end_units = region,
    n = 5
  )

  expect_false("year" %in% names(result))
  expect_equal(nrow(result), 5)
})

test_that("ec_upscale groups independently by year", {

  dat <- data.frame(
    value = c(2, 2, 4, 4, 6, 6, 8, 8),
    weight = 1,
    start_unit = c("A", "A", "B", "B",
                   "A", "A", "B", "B"),
    end_unit = "Norway",
    year = c(2020, 2020, 2020, 2020,
             2021, 2021, 2021, 2021)
  )

  result <- ec_upscale(
    data = dat,
    variable = value,
    weight = weight,
    start_units = start_unit,
    end_units = end_unit,
    year = year,
    n = 3
  )

  expect_equal(
    unique(result$sampled_value[result$year == 2020]),
    3
  )

  expect_equal(
    unique(result$sampled_value[result$year == 2021]),
    7
  )
})