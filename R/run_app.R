run_app <- function() {
  if (dir.exists("~/.cache/R/sass")) {
    unlink("~/.cache/R/sass", recursive = TRUE, force = TRUE)
  }

  shiny::addResourcePath("dir", system.file(package = "ShinyGBIF", "www"))

  shiny::shinyApp(ui = ui(), server = server, option = list(launch.browser = TRUE))
}
