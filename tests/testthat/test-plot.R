test_that("plot.timeline returns an echarts4r htmlwidget", {
  data <- tibble::tibble(
    year = as.Date(c("2020-01-01", "2021-01-01")),
    Observations = c(10L, 5L)
  )

  out <- plot.timeline(data)

  expect_s3_class(out, "htmlwidget")
  expect_equal(out$x$type, "echarts4r")
})

test_that("plot.timeline uses the first column as x-axis", {
  data <- tibble::tibble(
    month = 1:3,
    Observations = c(2L, 4L, 6L)
  )

  out <- plot.timeline(data)

  # x-axis data stored internally
  expect_true("month" %in% names(data))
  expect_true(any(grepl("Observations", names(out$x$series[[1]]))))
})

test_that("plot.ranking returns an echarts4r bar chart", {
  data <- tibble::tibble(
    Family = c("A", "B", "Others"),
    Observations = c(10L, 5L, 3L)
  )

  out <- plot.ranking(data)

  expect_s3_class(out, "htmlwidget")
  expect_equal(out$x$type, "echarts4r")
})

test_that("plot.ranking flips coordinates (horizontal bars)", {
  data <- tibble::tibble(
    Group = c("X", "Y"),
    Observations = c(1L, 2L)
  )

  out <- plot.ranking(data)

  expect_true(any(grepl("flip", names(out$x))))
})

