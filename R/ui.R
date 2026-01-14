ui <- function() {
  bslib::page_navbar(
    title = shiny::a(
      shiny::img(src = "dir/img/kamogawa_hanko.png", width = "48px"),
      href = "https://github.com/LKamogawa"
    ),
    window_title = "GBIF Observations Dashboard",
    fillable = FALSE,
    header = shiny::tagList(
      shiny::tags$head(
        shiny::tags$link(rel = "stylesheet", type = "text/css", href = "dir/css/styles.css")
      )
    ),
    footer = footer_ui()
  )
}
