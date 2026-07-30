#!/usr/bin/env Rscript
#
# Remove a branch preview deployment from Posit Connect (run on branch
# delete / PR close / merge).
#
# Usage:
#   Rscript deploy/cleanup.R <branch-name>
#
# Env vars required: CONNECT_SERVER, CONNECT_API_KEY
# Optional: APP_BASE_NAME (default "shinygbif"), PROD_BRANCH (default "finishing")

args <- commandArgs(trailingOnly = TRUE)
branch <- if (length(args) >= 1) args[[1]] else Sys.getenv("GITHUB_REF_NAME", "")
if (identical(branch, "")) stop("No branch supplied (arg or GITHUB_REF_NAME).")

server      <- Sys.getenv("CONNECT_SERVER")
api_key     <- Sys.getenv("CONNECT_API_KEY")
base_name   <- Sys.getenv("APP_BASE_NAME", "shinygbif")
prod_branch <- Sys.getenv("PROD_BRANCH", "finishing")

if (any(c(server, api_key) == "")) stop("CONNECT_SERVER and CONNECT_API_KEY must be set.")
if (identical(branch, prod_branch)) stop("Refusing to clean up the prod branch.")

slugify <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "-", x)
  x <- gsub("^-+|-+$", "", x)
  substr(x, 1, 60)
}

app_name <- paste0(base_name, "-", slugify(branch))
server <- sub("/+$", "", server)

resp <- httr::GET(
  paste0(server, "/__api__/v1/content"),
  query = list(name = app_name),
  httr::add_headers(Authorization = paste("Key", api_key))
)
httr::stop_for_status(resp)
content_list <- httr::content(resp, as = "parsed")

if (length(content_list) == 0) {
  message("No content named '", app_name, "' found, nothing to clean up.")
  quit(status = 0)
}

guid <- content_list[[1]]$guid
del <- httr::DELETE(
  paste0(server, "/__api__/v1/content/", guid),
  httr::add_headers(Authorization = paste("Key", api_key))
)
httr::stop_for_status(del)

message("Deleted content '", app_name, "' (guid: ", guid, ")")
