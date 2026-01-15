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
    echarts4r::e_color(c("#4C9C2E")) |>
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
    echarts4r::e_flip_coords()
}
