library(dplyr)
library(readr)

# First, let take a look in the data frame structure of both .csv files.
View(read_csv("~/Downloads/biodiversity-data/occurence.csv", n_max = 10000))
View(read_csv("~/Downloads/biodiversity-data/multimedia.csv", n_max = 10000))

# Now, we use readr::read_csv_chunk to handle this large occurence.csv file and use the `callback`
# argument to filter just the rows where `country %in% c("Poland", "Brazil")`.
occurrence_filter <- function(chunk, pos) {
  chunk |> filter(country %in% c("Poland", "Brazil"))
}

occurrence <- read_csv_chunked(
  "~/Downloads/biodiversity-data/occurence.csv",
  callback = DataFrameCallback$new(occurrence_filter)
)

# With the `ids` from `occurrence_poland`, we can filter the rows in multimedia.csv where
# `CoreId %in% `occurrence$id`.
multimedia_filter <- function(chunk, pos) {
  chunk |> filter(CoreId %in% occurrence$id)
}

multimedia <- read_csv_chunked(
  "~/Downloads/biodiversity-data/multimedia.csv",
  callback = DataFrameCallback$new(multimedia_filter)
)

# Finally, transform the data frames to .rda files to call in the app.
usethis::use_data(occurrence, overwrite = TRUE)
usethis::use_data(multimedia, overwrite = TRUE)


