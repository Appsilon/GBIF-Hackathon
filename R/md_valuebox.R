md.valuebox_ui <- function(id, header_text, icon = NULL) {
  ns <- shiny::NS(id)
  bslib::card(
    bslib::card_header(header_text),
    bslib::card_body(shiny::span(
      style = "display: flex; justify-content: space-between;",
      shiny::uiOutput(ns("body")),
      bsicons::bs_icon(icon, size = "2em")
    ))
    # bslib::card_footer(shiny::textOutput(ns("footer")))
  )
}

md.valuebox_server <- function(id, rc.data, .by) {
  shiny::moduleServer(id, function(input, output, session) {
    output$body <- shiny::renderUI({
      shiny::req(rc.data())
      df <- rc.data()$occurrence |> tidy.valuebox(.by = .by)

      if (id == "sex") {
        text <-
          df |>
          dplyr::mutate(
            Total = sum(Observations),
            Pct = paste0(round({Observations/Total * 100}, 2), "%"),
            Text = paste0(Sex, ": ", Observations, " observations (", Pct, ")")
          ) |>
          dplyr::pull(Text)

        return(
          shiny::p(
            style = "font-size: 13px;",
            shiny::HTML(paste(text, collapse = "<br>"))
          )
        )
      }

      if (id == "info") {
        kingdom <- rc.data()$occurrence |> dplyr::pull(kingdom) |> unique()
        family <- rc.data()$occurrence |> dplyr::pull(family) |> unique()

        text <- c(paste0("Kingdom: ", kingdom),  paste0("Family: ", family))

        return(
          shiny::p(
            style = "font-size: 13px;",
            shiny::HTML(paste(text, collapse = "<br>"))
          )
        )
      }

      shiny::p(style = "font-size: 24px; font-weight: bold;", df[[1]])
    })
  })
}
