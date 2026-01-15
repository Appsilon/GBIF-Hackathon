clean_id <- function(data) {
  sub("@OBS", "", data) |> as.integer()
}

my_theme <- bslib::bs_theme(
  primary = "#4C9C2E",
  secondary = "#231F20",
  base_font = bslib::font_google("Inter"),
  bg = "#fff",
  fg = "#231F20"
)
