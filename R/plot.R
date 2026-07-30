plot.timeline <- function(data) {
  x_name <- names(data)[[1]]
  max_idx <- which.max(data$Observations)
  max_x <- data[[x_name]][[max_idx]]
  max_y <- data$Observations[[max_idx]]
  mean_y <- mean(data$Observations, na.rm = TRUE)

  plotly::plot_ly(
    data,
    x = ~get(x_name),
    y = ~Observations,
    type = "scatter",
    mode = "lines",
    fill = "tozeroy",
    line = list(color = "#4C9C2E", width = 1.5),
    fillcolor = "rgba(76,156,46,0.85)",
    hovertemplate = "%{y}<extra></extra>"
  ) |>
    plotly::add_markers(
      x = max_x,
      y = max_y,
      marker = list(color = "#4C9C2E", size = 9),
      hovertemplate = paste0("Max: ", max_y, "<extra></extra>"),
      inherit = FALSE
    ) |>
    plotly::layout(
      showlegend = FALSE,
      hovermode = "x unified",
      xaxis = list(title = x_name, tickfont = list(size = 12)),
      yaxis = list(title = "Observations", tickfont = list(size = 12)),
      shapes = list(
        list(
          type = "line",
          xref = "paper", x0 = 0, x1 = 1,
          yref = "y", y0 = mean_y, y1 = mean_y,
          line = list(color = "#4C9C2E", width = 1, dash = "dash")
        )
      ),
      annotations = list(
        list(
          x = max_x, y = max_y,
          text = paste0("Max: ", max_y),
          showarrow = TRUE, arrowhead = 2, ax = 0, ay = -30
        )
      )
    ) |>
    plotly::rangeslider() |>
    plotly::config(responsive = TRUE)
}

plot.ranking <- function(data) {
  y_name <- names(data)[[1]]

  plotly::plot_ly(
    data,
    x = ~Observations,
    y = ~get(y_name),
    type = "bar",
    orientation = "h",
    marker = list(color = "#4C9C2E"),
    hovertemplate = "%{x}<extra></extra>"
  ) |>
    plotly::layout(
      showlegend = FALSE,
      hovermode = "y unified",
      xaxis = list(title = "Observations", tickfont = list(size = 12)),
      yaxis = list(
        title = "",
        tickfont = list(size = 12),
        categoryorder = "array",
        categoryarray = data[[y_name]]
      ),
      margin = list(l = 100)
    ) |>
    plotly::config(responsive = TRUE)
}

plt.maplibre <- function() {
  # Made with the help of Claude Sonnet 4.5
  mapgl::maplibre(
    style = mapgl::maptiler_style("openstreetmap", api_key = "xbKHifJb13l0cMLRyQUG"),# My API just for this
    center = c(19.8339408685461, 49.3105052885285),
    zoom = 5,
    maxZoom = 12
  )
}

plt.map_with_heatmap <- function(base_map, observations_sf) {
  # Made with the help of Claude Sonnet 4.5
  base_map |>
  mapgl::add_heatmap_layer(
    id = "observation_heatmap",
    source = observations_sf,
    heatmap_radius = 15,
    heatmap_color = mapgl::interpolate(
      property = "heatmap-density",
      values = seq(0, 1, 0.2),
      stops = c("transparent", viridisLite::viridis(5))
    ),
    heatmap_opacity = mapgl::interpolate(
      property = "zoom",
      values = c(8, 11),
      stops = c(1, 0)
    )
  ) |>
    mapgl::add_circle_layer(
    id = "observation_circles",
    source = observations_sf,
    circle_color = "#4C9C2E",
    circle_stroke_color = "white",
    circle_stroke_width = 2,
    circle_radius = 8,
    min_zoom = 9.5,
    popup = "popup_content"
  )
}
