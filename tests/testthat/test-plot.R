test_that("plot.timeline returns a plotly htmlwidget", {
  data <- tibble::tibble(
    year = as.Date(c("2020-01-01", "2021-01-01")),
    Observations = c(10L, 5L)
  )

  out <- plot.timeline(data)

  expect_s3_class(out, "htmlwidget")
  expect_s3_class(out, "plotly")
})

test_that("plot.timeline uses the first column as x-axis", {
  data <- tibble::tibble(
    month = 1:3,
    Observations = c(2L, 4L, 6L)
  )

  out <- plotly::plotly_build(plot.timeline(data))

  # first column is mapped to the x-axis title
  expect_true("month" %in% names(data))
  expect_equal(out$x$layout$xaxis$title, "month")
})

test_that("plot.ranking returns a plotly bar chart", {
  data <- tibble::tibble(
    Family = c("A", "B", "Others"),
    Observations = c(10L, 5L, 3L)
  )

  out <- plot.ranking(data)

  expect_s3_class(out, "htmlwidget")
  expect_s3_class(out, "plotly")
})

test_that("plot.ranking draws horizontal bars", {
  data <- tibble::tibble(
    Group = c("X", "Y"),
    Observations = c(1L, 2L)
  )

  out <- plotly::plotly_build(plot.ranking(data))

  expect_equal(out$x$data[[1]]$orientation, "h")
})
