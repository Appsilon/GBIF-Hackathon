md.info_ui <- function(id = "info") {
  ns <- shiny::NS(id)

  shiny::div(
    shiny::actionLink(
      ns("info"),
      label = NULL,
      icon = shiny::icon("circle-info", style = "color: #2255ce !important;")
      )
    )
}

md.info_server <- function(id = "info") {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observe({
      shiny::showModal(shiny::modalDialog(
        title = "GBIF Dashboard Info",
        footer = shiny::modalButton("Close"),
        size = "l",
        easyClose = TRUE,
        info_text
      ))
    }) |>
      shiny::bindEvent(input$info)
  })
}
