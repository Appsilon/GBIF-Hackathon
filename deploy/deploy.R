#!/usr/bin/env Rscript
#
# Deploy this app to Posit Connect.
#
# Usage:
#   Rscript deploy/deploy.R <branch-name>
#
# Env vars required:
#   CONNECT_SERVER   - e.g. https://connect.example.com
#   CONNECT_API_KEY  - API key with publish rights
#   CONNECT_ACCOUNT  - account/username the content is published under
#
# Optional:
#   APP_BASE_NAME    - base app name, default "shinygbif"
#   PROD_BRANCH      - branch treated as prod, default "finishing"

args <- commandArgs(trailingOnly = TRUE)
branch <- if (length(args) >= 1) args[[1]] else Sys.getenv("GITHUB_REF_NAME", "")
if (identical(branch, "")) stop("No branch supplied (arg or GITHUB_REF_NAME).")

server      <- Sys.getenv("CONNECT_SERVER")
api_key     <- Sys.getenv("CONNECT_API_KEY")
account     <- Sys.getenv("CONNECT_ACCOUNT")
base_name   <- Sys.getenv("APP_BASE_NAME", "shinygbif")
prod_branch <- Sys.getenv("PROD_BRANCH", "finishing")

if (any(c(server, api_key, account) == "")) {
  stop("CONNECT_SERVER, CONNECT_API_KEY, CONNECT_ACCOUNT must all be set.")
}

slugify <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "-", x)
  x <- gsub("^-+|-+$", "", x)
  substr(x, 1, 60)
}

is_prod <- identical(branch, prod_branch)
app_name  <- if (is_prod) base_name else paste0(base_name, "-", slugify(branch))
app_title <- if (is_prod) "ShinyGBIF (prod)" else paste0("ShinyGBIF - ", branch)

server_name <- "connect"

if (!server_name %in% rsconnect::servers()$name) {
  rsconnect::addServer(url = server, name = server_name)
}

accounts <- rsconnect::accounts(server = server_name)
if (!account %in% accounts$name) {
  rsconnect::connectApiUser(account = account, server = server_name, apiKey = api_key)
}

message(sprintf("Deploying branch '%s' as app '%s' (%s)...",
                 branch, app_name, if (is_prod) "PROD" else "preview"))

rsconnect::deployApp(
  appDir       = ".",
  appName      = app_name,
  appTitle     = app_title,
  account      = account,
  server       = server_name,
  forceUpdate  = TRUE,
  launch.browser = FALSE
)

message("Deployed: ", app_name)

# look up the content's URL via the Connect API (same approach as
# cleanup.R) so callers can grab it without parsing rsconnect's log output
resp <- httr::GET(
  paste0(sub("/+$", "", server), "/__api__/v1/content"),
  query = list(name = app_name),
  httr::add_headers(Authorization = paste("Key", api_key))
)
httr::stop_for_status(resp)
content_list <- httr::content(resp, as = "parsed")
if (length(content_list) == 0) stop("Deployed but couldn't find content '", app_name, "' to resolve its URL.")

content_url <- content_list[[1]]$content_url
message("DEPLOY_URL=", content_url)
