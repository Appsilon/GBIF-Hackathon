ui <- function() {

  title <- shiny::tagList(
    shiny::a(
      id = "title-logo",
      shiny::img(src = "dir/img/kamogawa_hanko.png", width = "48px"),
      href = "https://github.com/LKamogawa"
    ),
    shiny::span("GBIF Dashboard")
  )

  nav_items <- bslib::nav_item(
    bslib::nav_item("1"),
    bslib::nav_item("2"),
    bslib::nav_item("3"),
    bslib::nav_item("4")
  )

  body_layout <- bslib::layout_columns(
    col_widths = c(7, 5),
    style = "margin: 15px;",
      bslib::layout_columns(
        col_widths = c(
          4, 4, 4,
          6, 6,
          12
        ),
        row_heights = c(1, 2, 2),
        style = "overflow: auto;",
        bslib::card(), bslib::card(), bslib::card(),
        bslib::card(), bslib::card(),
        bslib::card()
      ),
    bslib::card()
  )

  bslib::page_navbar(
    title = shiny::tagList(title, info_ui()),
    window_title = "GBIF Observations Dashboard",
    fillable = TRUE,
    header = shiny::tagList(
      shiny::tags$head(
        shiny::tags$link(rel = "stylesheet", type = "text/css", href = "dir/css/styles.css")
      )
    ),
    footer = footer_ui(),
    bslib::nav_spacer(),
    nav_items,
    body_layout
  )
}
