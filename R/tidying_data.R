tidy.occurrence <- function(data) {
  data |>
    dplyr::mutate(
      id = clean_id(id),
      name = dplyr::if_else(
        is.na(vernacularName),
        stringr::str_to_sentence(scientificName),
        paste0(
          stringr::str_to_sentence(scientificName), " (", stringr::str_to_title(vernacularName), ")"
        )
      ),
      kingdom = stringr::str_to_title(kingdom),
      family = family |> stringr::word(-1, sep = "_") |> stringr::str_to_title(),
      individual_count = as.integer(individualCount),
      life_stage = stringr::str_to_title(lifeStage),
      sex = stringr::str_to_title(sex),
      lat = as.double(latitudeDecimal),
      long = as.double(longitudeDecimal),
      continent = stringr::str_to_title(continent),
      country = stringr::str_to_title(country),
      locality = stringr::str_to_title(locality),
      event_date = as.Date(eventDate),
      event_time = eventTime,
      .keep = "none"
     )
}

tidy.multimedia <- function(data) {
  data |>
    dplyr::mutate(
      id = clean_id(CoreId),
      image_url = as.character(accessURI),
      creator = stringr::str_to_title(creator),
      rights_holder = as.character(rightsHolder),
      license = as.character(license),
      .keep = "none"
    )
}

tidy.timeline <- function(data, period = c("year", "month", "hour")) {
  period <- match.arg(period)

  df <-
    data |>
    dplyr::mutate(
      individual_count,
      year = lubridate::floor_date(event_date, "year"),
      month = lubridate::month(event_date) |> as.integer(),
      hour = hms::as_hms(event_time) |> lubridate::hour() |> as.integer(),
      .keep = "none"
    ) |>
    dplyr::summarise(Observations = sum(individual_count, na.rm = TRUE), .by = period) |>
    dplyr::arrange(!!dplyr::sym(period))

  complete_vector <- switch(
    period,
    year = df |> dplyr::pull(1) |> (\(x) seq.Date(x[[1]], x[[length(x)]], "year"))(),
    month = seq.int(1, 12, 1),
    hour = seq.int(1, 23, 1)
  )

  df |>
    tidyr::drop_na() |>
    tidyr::complete(!!dplyr::sym(period) := complete_vector, fill = list(Observations = 0L))
}

tidy.ranking <- function(data, n = 4, .by = NULL) {
  data |>
    dplyr::summarise(Observations = sum(individual_count, na.rm = FALSE), .by = .by) |>
    dplyr::arrange(dplyr::desc(Observations)) |>
    dplyr::mutate(
      !!dplyr::sym(.by) := dplyr::if_else(dplyr::row_number() > n, "Others", !!dplyr::sym(.by))
      ) |>
    dplyr::summarise(Observations = sum(Observations), .by = .by)
}
