server <- function(input, output, session) {

  occurrence_data <- tidy.occurrence(occurrence)
  multimedia_data <- tidy.multimedia(multimedia)

  rc.name <- md.select_input_server("name", sort(unique(occurrence_data$name)))

  rc.continent_vector <- shiny::reactive({
    shiny::req(rc.name())
    occurrence_data |>
      dplyr::filter(name == rc.name()) |>
      dplyr::pull(continent) |>
      unique() |>
      sort()
  })

  rc.continents <- md.select_input_server("continent", rc.continent_vector)

  rc.country_vector <- shiny::reactive({
    shiny::req(rc.name(), rc.continents())
    occurrence_data |>
      dplyr::filter(name == rc.name(), continent %in% rc.continents()) |>
      dplyr::pull(country) |>
      unique() |>
      sort()
  })

  rc.countries <- md.select_input_server("country", rc.country_vector)

  rv <- shiny::reactiveValues()

  rc.data <- shiny::reactive({
    shiny::req(rc.name(), rc.continents(), rc.countries())
    occurrence <-
      occurrence_data |>
      dplyr::filter(name == rc.name(), continent %in% rc.continents(), country %in% rc.countries())

    multimedia <-
      multimedia_data |>
      dplyr::inner_join(dplyr::select(occurrence, id))

    list(occurrence = occurrence, multimedia = multimedia)
  }) |>
    shiny::bindCache(rc.name(), rc.continents(), rc.countries())

  md.info_server()
  md.valuebox_server("observations", rc.data = rc.data, .by = NULL)
  md.valuebox_server("sex", rc.data = rc.data, .by = "sex")
  md.valuebox_server("info", rc.data = rc.data, .by = NULL)
  md.ranking_server("life_stage", rc.data = rc.data)
  md.ranking_server("country", rc.data = rc.data, n = 7)
  md.timeline_server("timeline", rc.data = rc.data)
  md.map_server("map", rc.data = rc.data)
  md.footer_server()

  shiny::observe({
    print(rc.name())
    print(rc.continents())
    print(rc.countries())
    print(rc.data())
  })
}
