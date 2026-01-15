md.map_ui <- function(id, header_text) {
  ns <- shiny::NS(id)

  bslib::card(
    bslib::card_header(header_text),
    bslib::card_body(leaflet::leafletOutput(ns("map")), padding = 0)
  )
}

md.map_server <- function(id, rc.data) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$map <- leaflet::renderLeaflet({
      plt.leaflet()
    })

    observe({
      req(rc.data())

      leaflet::leafletProxy(ns("map")) |>
        leaflet::clearMarkerClusters() |>
        leaflet::clearMarkers() |>
        plt.leaflet_markers(data = rc.data()$occurrence)
    })
  })
}
