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

  shiny::observe({
    rv$name <- rc.name()
    rv$continents <- rc.continents()
    rv$countries <- rc.countries()
    print(rv$name)
    print(rv$continents)
    print(rv$countries)
  })

  rc.data <- shiny::reactive({
    occurrence <-
      occurrence_data |>
      dplyr::filter(name == rv$name, continent %in% rv$continents, country %in% rv$countries)

    multimedia <-
      multimedia_data |>
      dplyr::inner_join(dplyr::select(occurrence, id))

    list(occurrence = occurrence, multimedia = multimedia)
  }) |>
    shiny::bindCache(rv$name, rv$continents, rv$countries)

  md.footer_server()
  md.info_server()
}
