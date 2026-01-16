test_that("tidy.occurrence cleans and standardizes fields", {
  raw <- tibble::tibble(
    id = " 123 ",
    vernacularName = NA_character_,
    scientificName = "panthera leo",
    kingdom = "animalia",
    family = "felidae_big",
    individualCount = "3",
    lifeStage = "adult",
    sex = "male",
    latitudeDecimal = "-10.5",
    longitudeDecimal = "20.2",
    continent = "africa",
    country = "brazil",
    locality = "rio de janeiro",
    eventDate = "2020-01-01",
    eventTime = "12:00:00"
  )

  out <- tidy.occurrence(raw)

  expect_named(
    out,
    c(
      "id", "name", "kingdom", "family", "individual_count",
      "life_stage", "sex", "lat", "long", "continent",
      "country", "locality", "event_date", "event_time"
    )
  )

  expect_s3_class(out$event_date, "Date")
  expect_type(out$lat, "double")
  expect_type(out$individual_count, "integer")

  expect_equal(out$name, "Panthera leo")
  expect_equal(out$family, "Big")
  expect_equal(out$kingdom, "Animalia")
})

test_that("tidy.multimedia selects and renames multimedia fields", {
  raw <- tibble::tibble(
    CoreId = "001",
    accessURI = "http://example.com/img.jpg",
    creator = "john doe",
    rightsHolder = "GBIF",
    license = "CC-BY"
  )

  out <- tidy.multimedia(raw)

  expect_named(
    out,
    c("id", "image_url", "creator", "rights_holder", "license")
  )

  expect_equal(out$creator, "John Doe")
  expect_type(out$image_url, "character")
})

test_that("tidy.timeline aggregates observations by year", {
  raw <- tibble::tibble(
    individual_count = c(1L, 2L, 3L),
    event_date = as.Date(c("2020-01-01", "2020-06-01", "2021-01-01")),
    event_time = c("10:00:00", "11:00:00", "12:00:00")
  )

  out <- tidy.timeline(raw, period = "year")

  expect_named(out, c("year", "Observations"))
  expect_equal(sum(out$Observations), 6)
  expect_true(all(out$Observations >= 0))
})

test_that("tidy.timeline completes missing months", {
  raw <- tibble::tibble(
    individual_count = c(1L, 1L),
    event_date = as.Date(c("2020-01-01", "2020-03-01")),
    event_time = c("10:00:00", "10:00:00")
  )

  out <- tidy.timeline(raw, period = "month")

  expect_equal(nrow(out), 12)
  expect_true(any(out$Observations == 0))
})

test_that("tidy.ranking groups lower ranks as Others", {
  raw <- tibble::tibble(
    family = c("A", "B", "C", "D", "E"),
    individual_count = c(10, 9, 8, 1, 1)
  )

  out <- tidy.ranking(raw, .by = "family", n = 3)

  expect_named(out, c("Family", "Observations"))
  expect_true("Others" %in% out$Family)
  expect_equal(sum(out$Observations), sum(raw$individual_count))
})

test_that("tidy.valuebox summarizes observations by group", {
  raw <- tibble::tibble(
    sex = c("Male", "Female", "Male"),
    individual_count = c(1, 2, 3)
  )

  out <- tidy.valuebox(raw, .by = "sex")

  expect_named(out, c("Sex", "Observations"))
  expect_equal(sum(out$Observations), 6)
})

test_that("tidy.coords_sf returns an sf object with geometry", {
  raw <- tibble::tibble(
    lat = c(-10, -11),
    long = c(20, 21)
  )

  out <- tidy.coords_sf(raw)

  expect_s3_class(out, "sf")
  expect_true("geometry" %in% names(out))
})

test_that("tidy.map_popup creates popup_content HTML", {
  raw <- tibble::tibble(
    name = "Panthera leo",
    event_date = as.Date("2020-01-01"),
    event_time = "12:00",
    individual_count = 2,
    life_stage = "Adult",
    sex = "Male",
    locality = "Savannah",
    images = NA_character_
  )

  out <- tidy.map_popup(raw)

  expect_true("popup_content" %in% names(out))
  expect_true(grepl("<div", out$popup_content))
  expect_false(any(c("popup_id", "images_processed") %in% names(out)))
})
