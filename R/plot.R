plot.timeline <- function(data) {
  data |>
    echarts4r::e_charts_(names(data)[[1]]) |>
    echarts4r::e_area(
      Observations,
      lineStyle = list(opacity = 0.85, width = 1.5),
      itemStyle = list(opacity = 1),
      symbol = "none",
      legend = list(show = FALSE)
    ) |>
    echarts4r::e_x_axis(axisLabel = list(fontSize = 12)) |>
    echarts4r::e_y_axis(axisLabel = list(fontSize = 12)) |>
    echarts4r::e_mark_point(data = list(name = "Max", type = "max")) |>
    echarts4r::e_mark_line(data = list(name = "Mean", type = "average"), precision = 0) |>
    echarts4r::e_color("#1A6FB5") |>
    echarts4r::e_tooltip(trigger = "axis") |>
    echarts4r::e_toolbox(emphasis = list(iconStyle = list(color = "#1A6FB5", borderColor = "#1A6FB5"))) |>
    echarts4r::e_toolbox_feature(feature = "magicType", type = list("line", "bar")) |>
    echarts4r::e_datazoom(toolbox = FALSE)
}

plot.ranking <- function(data) {
  data |>
    echarts4r::e_charts_(names(data)[[1]]) |>
    echarts4r::e_bar(
      Observations,
      lineStyle = list(opacity = 0.85, width = 1.5),
      itemStyle = list(opacity = 1),
      symbol = "none",
      legend = list(show = FALSE)
    ) |>
    echarts4r::e_x_axis(axisLabel = list(fontSize = 12)) |>
    echarts4r::e_y_axis(axisLabel = list(fontSize = 12)) |>
    echarts4r::e_color(c("#1A6FB5")) |>
    echarts4r::e_tooltip(trigger = "axis") |>
    echarts4r::e_flip_coords() |>
    echarts4r::e_grid(left = 100)
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
    circle_color = "#1A6FB5",
    circle_stroke_color = "white",
    circle_stroke_width = 2,
    circle_radius = 8,
    min_zoom = 9.5,
    popup = "popup_content"
  )
}
