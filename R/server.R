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
  }) |>
    shiny::bindCache(rc.name(), rc.continents())

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

  md.footer_server()
  md.info_server()
}
