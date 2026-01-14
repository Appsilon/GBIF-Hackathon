library(dplyr)
library(readr)

# First, let take a look in the data frame structure of both .csv files.
View(read_csv("~/Downloads/biodiversity-data/occurence.csv", n_max = 10000))
View(read_csv("~/Downloads/biodiversity-data/multimedia.csv", n_max = 10000))

# Now, we use readr::read_csv_chunk to handle this large occurence.csv file and use the `callback`
# argument to filter just the rows where `country == "Poland"`.
occurence_filter <- function(chunk, pos) {
  chunk |> filter(country == "Poland")
}

occurence_poland <- read_csv_chunked(
  "~/Downloads/biodiversity-data/occurence.csv",
  callback = DataFrameCallback$new(occurence_filter)
)

# With the `ids` from `occurence_poland`, we can filter the rows in multimedia.csv where
# `CoreId %in% `occurence_poland$id`.
multimedia_filter <- function(chunk, pos) {
  chunk |> filter(CoreId %in% occurence_poland$id)
}

multimedia_poland <- read_csv_chunked(
  "~/Downloads/biodiversity-data/multimedia.csv",
  callback = DataFrameCallback$new(multimedia_filter)
)

# Finally, transform the data frames to .rda files to call in the app.
usethis::use_data(occurence_poland, overwrite = TRUE)
usethis::use_data(multimedia_poland, overwrite = TRUE)


