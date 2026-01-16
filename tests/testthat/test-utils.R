test_that("clean_id removes '@OBS' and coerces to integer", {
  x <- "@OBS123"

  out <- clean_id(x)

  expect_type(out, "integer")
  expect_equal(out, 123L)
})

test_that("clean_id works on character vectors", {
  x <- c("@OBS1", "@OBS2", "@OBS10")

  out <- clean_id(x)

  expect_equal(out, c(1L, 2L, 10L))
})

test_that("clean_id returns NA for non-numeric values", {
  x <- c("@OBSABC", "@OBS")

  out <- suppressWarnings(clean_id(x))

  expect_true(all(is.na(out)))
})

test_that("clean_id leaves numeric-looking strings unchanged apart from prefix", {
  x <- c("001", "@OBS002")

  out <- clean_id(x)

  expect_equal(out, c(1L, 2L))
})

test_that("clean_id handles missing values", {
  x <- c(NA_character_, "@OBS5")

  out <- clean_id(x)

  expect_equal(out, c(NA_integer_, 5L))
})
