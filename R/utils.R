clean_id <- function(data) {
  sub("@OBS", "", data) |> as.integer()
}
