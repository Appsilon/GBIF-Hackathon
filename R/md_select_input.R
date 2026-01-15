md.select_input_ui <- function(
    id,
    label = NULL,
    searchPlaceholderText = NULL,
    multiple = FALSE,
    width = "auto"
) {
  ns <- shiny::NS(id)

  bslib::nav_item(
    wd.virtual_select_input(
      inputId = ns("select_input"),
      label = label,
      searchPlaceholderText = searchPlaceholderText,
      multiple = multiple,
      width = width
    )
  )
}

md.select_input_server <- function(id, choices_vector) {
  shiny::moduleServer(id, function(input, output, session) {

    shiny::observe({
      choices <- if (shiny::is.reactive(choices_vector)) {
        choices_vector()
      } else {
        choices_vector
      }

      shiny::req(choices)
      shinyWidgets::updateVirtualSelect(
        inputId = "select_input",
        choices = choices,
        selected = choices[[1]]
      )
    })

    return(shiny::reactive({input$select_input}))
  })
}
