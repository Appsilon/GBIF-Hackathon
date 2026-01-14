server <- function(input, output, session) {

  raw_data <- list(occurrence = occurence_poland, multimedia = multimedia_poland)

  occurrence_data <- tidy.occurrence(raw_data$occurrence)
  multimedia_data <- tidy.multimedia(raw_data$multimedia)

  md.footer_server()
  md.info_server()
}
