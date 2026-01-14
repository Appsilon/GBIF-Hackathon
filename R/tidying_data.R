tidy_occurrence <- function(data) {
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

# multimedia_poland <-
#   multimedia_poland |>
#   dplyr::select(CoreId, image_url = accessURI, creator, rightsHolder, license)

tidy_multimedia <- function(data) {
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
