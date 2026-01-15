md.ranking_ui <- function(id, header_text) {
  ns <- shiny::NS(id)
  bslib::card(
    bslib::card_header(header_text),
    bslib::card_body(echarts4r::echarts4rOutput(ns("plot")))
  )
}

md.ranking_server <- function(id, rv, rc.data, n = 4) {
  shiny::moduleServer(id, function(input, output, session) {
      output$plot <- echarts4r::renderEcharts4r({

        shiny::validate(
          shiny::need(rv$continent, "Select at least one continent to visualize data."),
          shiny::need(rv$country, "Select at least one country to visualize data.")
        )

        shiny::req(rc.data())
        rc.data()$occurrence |>
          tidy.ranking(.by = id, n = n) |>
          plot.ranking()
      })
  })
}
