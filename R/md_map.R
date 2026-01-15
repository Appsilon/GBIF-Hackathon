md.map_ui <- function(id, header_text) {
  ns <- shiny::NS(id)

  bslib::card(
    bslib::card_header(header_text),
    bslib::card_body(mapgl::maplibreOutput(ns("map")), padding = 0)
  )
}

md.map_server <- function(id, rc.data) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Made with the help of Claude Sonnet 4.5

    output$map <- mapgl::renderMaplibre({
      plt.maplibre()
    })

    shiny::observe({

      media_info <-
        rc.data()$multimedia |>
        dplyr::group_by(id, creator, license, rights_holder) |>
        dplyr::summarise(images = paste(image_url, collapse = ","), .groups = "drop")

      occurrence_with_media <-
        rc.data()$occurrence |>
        dplyr::left_join(media_info)

      observations_sf <- tidy.coords_sf(occurrence_with_media) |> tidy.map_popup()

      mapgl::maplibre_proxy(ns("map")) |>
        mapgl::clear_layer(c("observation_heatmap", "observation_circles")) |>
        plt.map_with_heatmap(observations_sf = observations_sf)
    })
  })
}
