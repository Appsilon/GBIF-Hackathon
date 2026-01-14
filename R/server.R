server <- function(input, output, session) {

  raw_data <- list(occurrence = occurence_poland, multimedia = multimedia_poland)

  occurrence_data <- tidy_occurrence(raw_data$occurrence)
  multimedia_data <- tidy_multimedia(raw_data$multimedia)

  footer_server()
  info_server()
}
