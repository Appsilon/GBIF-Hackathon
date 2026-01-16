run_app <- function() {
  shiny::addResourcePath("dir", system.file(package = "ShinyGBIF", "www"))

  options(sass.cache = FALSE)

  shiny::shinyApp(ui = ui(), server = server, option = list(launch.browser = TRUE))
}
