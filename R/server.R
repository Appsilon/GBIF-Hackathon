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

  rv <- shiny::reactiveValues()

  shiny::observe({
    rv$continent <- rc.continents()
    rv$country <- rc.countries()
  })

  md.info_server()
  md.valuebox_server("observations", rv = rv, rc.data = rc.data, .by = NULL)
  md.valuebox_server("sex", rv = rv, rc.data = rc.data, .by = "sex")
  md.valuebox_server("info", rv = rv, rc.data = rc.data, .by = NULL)
  md.ranking_server("life_stage", rv = rv, rc.data = rc.data)
  md.ranking_server("country", rv = rv, rc.data = rc.data, n = 7)
  md.timeline_server("timeline", rv = rv, rc.data = rc.data)
  md.map_server("map", rc.data = rc.data)
  md.footer_server()
}
