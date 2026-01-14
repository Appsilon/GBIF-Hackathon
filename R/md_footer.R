footer_ui <- function(id = "footer") {
  ns <- shiny::NS(id)

  shiny::div(
    id = "footer",
    shiny::span(
      id = "footer-left",
      "Made with 💙 by ",
      shiny::a("Leonardo Kamogawa", href = "https://github.com/LKamogawa")
    ),
    shiny::span(
      id = "footer-right",
      "This dashboard is licensed under ",
      shiny::actionLink(ns("modal"), "MIT License")
    )
  )
}

footer_server <- function(id = "footer") {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observe({
      shiny::showModal(shiny::modalDialog(
        title = "MIT License",
        footer = shiny::modalButton("Close"),
        size = "l",
        easyClose = TRUE,
        mit_license_text
      ))
    }) |>
      shiny::bindEvent(input$modal)
  })
}
