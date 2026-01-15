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
    echarts4r::e_color("#4C9C2E") |>
    echarts4r::e_tooltip(trigger = "axis") |>
    echarts4r::e_toolbox(emphasis = list(iconStyle = list(color = "#4C9C2E", borderColor = "#4C9C2E"))) |>
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
    echarts4r::e_color(c("#4C9C2E")) |>
    echarts4r::e_tooltip(trigger = "axis") |>
    echarts4r::e_flip_coords() |>
    echarts4r::e_grid(left = 100)
}

plt.leaflet <- function(pal) {
  leaflet::leaflet() |>
    leaflet::setView(lng = 19.8339408685461, lat = 49.3105052885285, zoom = 5) |>
    leaflet::addProviderTiles(providers$CartoDB.Positron)
}

plt.leaflet_markers <- function(map, data) {
  map |>
    leaflet::addCircleMarkers(
      data = data,
      lng = ~long,
      lat = ~lat,
      popup = ~paste(
        "<div style='font-size: 18px; font-weight: bold; color: #c46479; margin-bottom: 10px;'>", name, "</div>",
        "<div style='display: flex; align-items: flex-start;'>",
        "<div style='flex: 1; padding-right: 10px;'>",
        "<b>Date:</b> ", event_date, "<br>",
        "<b>Time:</b> ", event_time, "<br>",
        "<b>Observations:</b> ", individual_count, "<br>",
        "<b>Life stage:</b> ", life_stage, "<br>",
        "<b>Sex:</b> ", sex, "<br>",
        "<b>Locality:</b> ", locality, "<br>",
        "<b>Coordinates:</b> ", long, lat,
        "</div>",
        "</div>"
      ),
      fillColor = "#4C9C2E",
      fillOpacity = 1,
      stroke = FALSE,
      options = leaflet::markerOptions(
        riseOnHover = TRUE,
        individual_count = ~individual_count
      )
      # clusterOptions = leaflet::markerClusterOptions(
      #   iconCreateFunction = fx.custom_marker_clustering_js
      #   )
    )
}
