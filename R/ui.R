ui <- function() {

  title <- shiny::tagList(
    shiny::a(
      id = "title-logo",
      shiny::img(src = "dir/img/gbif-standard-logo-green.png", width = "108px"),
      href = "https://www.gbif.org/"
    ),
    shiny::span("GBIF Dashboard")
  )

  nav_items <- bslib::nav_item(
    md.select_input_ui(
      "name",
      label = "Species Name",
      searchPlaceholderText = "Enter a vernacular or scientific name…",
      multiple = FALSE,
      width = "500px"
    ),
    md.select_input_ui(
      "continent",
      label = "Continents",
      searchPlaceholderText = "Enter a continent name…",
      multiple = TRUE,
      width = "250px"
    ),
    md.select_input_ui(
      "country",
      label = "Countries",
      searchPlaceholderText = "Enter a country name…",
      multiple = TRUE,
      width = "250px"
    )
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
      row_heights = c(1, 2, 3),
      style = "overflow: auto;",
      md.valuebox_ui("observations", "Total of observations (Estimated)", "binoculars-fill"),
      md.valuebox_ui("sex", "Sex distribution", "gender-ambiguous"),
      md.valuebox_ui("info", "Trivia", "diagram-3-fill"),
      md.ranking_ui("life_stage", "Life stage ranking"),
      md.ranking_ui("country", "Country ranking"),
      md.timeline_ui()
    ),
    bslib::card()
  )

  bslib::page_navbar(
    title = shiny::tagList(title, md.info_ui()),
    window_title = "GBIF Observations Dashboard",
    fillable = TRUE,
    header = shiny::tagList(
      shiny::tags$head(
        shiny::tags$link(rel = "stylesheet", type = "text/css", href = "dir/css/styles.css")
      )
    ),
    footer = md.footer_ui(),
    bslib::nav_spacer(),
    nav_items,
    body_layout
  )
}
