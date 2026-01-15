md.timeline_ui <- function(id = "timeline") {
  ns <- shiny::NS(id)

  bslib::card(
    bslib::card_header("Timeline"),
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        open = FALSE,
        shinyWidgets::radioGroupButtons(
          ns("radio"),
          label = "Group by",
          choices = c("Year", "Month", "Hour"),
          direction = "vertical",
        )
      ),
      bslib::card_body(echarts4r::echarts4rOutput(ns("plot")))
    )
  )
}

md.timeline_server <- function(id = "timeline", rc.data) {
  shiny::moduleServer(id, function(input, output, session) {

    output$plot <- echarts4r::renderEcharts4r({
      shiny::req(rc.data())
      rc.data()$occurrence |> tidy.timeline(stringr::str_to_lower(input$radio)) |> plot.timeline()
    })
  })
}
