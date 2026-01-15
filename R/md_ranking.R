md.ranking_ui <- function(id, header_text) {
  ns <- shiny::NS(id)

  bslib::card(
    bslib::card_header(header_text),
    bslib::card_body(echarts4r::echarts4rOutput(ns("plot")))
  )
}

md.ranking_server <- function(id, .by, rc.data, n = 4) {
  shiny::moduleServer(id, function(input, output, session) {

    output$plot <- echarts4r::renderEcharts4r({
      shiny::req(rc.data())
      rc.data()$occurrence |>
        tidy.ranking(.by = .by, n = n) |>
        plot.ranking()
    })
  })
}
