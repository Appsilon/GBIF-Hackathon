# GitHub connection for the chatbot.
#
# Uses the {gh} package (GitHub REST API) so the assistant can inspect the
# repository (READ-ONLY) and open issues describing changes a (possibly
# non-technical) user requests directly from the app. It never modifies files
# in the repository. Requires a GITHUB_PAT / GITHUB_TOKEN with read access to
# the code and permission to open issues on the repository below.

gh_repo <- list(owner = "Appsilon", repo = "GBIF-Hackathon")

# Extra system-prompt block shared by every category: how to use the tools.
chat_issue_instructions <- paste(
  "You are connected to the GitHub repository",
  paste0(gh_repo$owner, "/", gh_repo$repo), "in READ-ONLY mode through tools.",
  "You can inspect the code but you must NOT and cannot modify any files.",
  "Your job is to turn the user's suggestion into a clear GitHub issue for the",
  "development team to action. Workflow:",
  "(1) Use `list_repo_files` and `read_repo_file` to understand the relevant",
  "code so the issue is concrete and references the right files.",
  "(2) Decide whether the user's request genuinely fits your responsibility for",
  "this category. If it does not, politely explain why and do NOT open an issue.",
  "(3) When the request is valid, call `propose_issue`. This does NOT open the",
  "issue directly: it shows the user a summary and asks them to confirm first.",
  "Before calling it, briefly summarise in chat what the issue will say.",
  "Never assume it was confirmed — wait for the user's decision, then share the",
  "returned issue link. Keep the conversation friendly for non-technical users."
)

# --- Low-level GitHub helpers ----------------------------------------------

gh.list_files <- function(path = "") {
  endpoint <- if (nzchar(path)) {
    "GET /repos/{owner}/{repo}/contents/{path}"
  } else {
    "GET /repos/{owner}/{repo}/contents"
  }
  res <- tryCatch(
    gh::gh(endpoint, owner = gh_repo$owner, repo = gh_repo$repo, path = path),
    error = function(e) NULL
  )
  if (is.null(res)) return(paste0("Path not found: ", path))
  paste(vapply(res, function(x) paste0(x$type, "\t", x$path), character(1)), collapse = "\n")
}

gh.read_file <- function(path) {
  res <- tryCatch(
    gh::gh(
      "GET /repos/{owner}/{repo}/contents/{path}",
      owner = gh_repo$owner, repo = gh_repo$repo, path = path
    ),
    error = function(e) NULL
  )
  if (is.null(res) || is.null(res$content)) return(paste0("File not found: ", path))
  rawToChar(jsonlite::base64_dec(gsub("\\s", "", res$content)))
}

gh.open_issue <- function(title, body) {
  tryCatch({
    issue <- gh::gh(
      "POST /repos/{owner}/{repo}/issues",
      owner = gh_repo$owner, repo = gh_repo$repo,
      title = title, body = body
    )
    paste0("Issue opened: ", issue$html_url)
  }, error = function(e) {
    paste0("Failed to open the issue: ", conditionMessage(e))
  })
}

# --- ellmer tool definitions ------------------------------------------------

# `propose` is a callback supplied by the chat server that shows the user a
# summary and asks them to confirm before the issue is actually opened.
gh.chat_tools <- function(propose) {
  list(
    ellmer::tool(
      gh.list_files,
      "List files and directories in the GitHub repository at a given path.",
      name = "list_repo_files",
      arguments = list(
        path = ellmer::type_string(
          "Repository path to list, e.g. 'R'. Empty string lists the repository root.",
          required = FALSE
        )
      )
    ),
    ellmer::tool(
      gh.read_file,
      "Read the full contents of a file in the GitHub repository.",
      name = "read_repo_file",
      arguments = list(
        path = ellmer::type_string("Repository-relative path to the file, e.g. 'R/ui.R'.")
      )
    ),
    ellmer::tool(
      function(title, body) propose(title, body),
      paste(
        "Propose a GitHub issue describing the requested change. This shows the",
        "user a summary and asks them to confirm before the issue is opened.",
        "Only call this when the request is valid for the selected category."
      ),
      name = "propose_issue",
      arguments = list(
        title = ellmer::type_string("Short, descriptive issue title."),
        body = ellmer::type_string(paste(
          "Detailed issue body in Markdown: the requested change, why it is",
          "wanted, and any relevant files/code paths you found to help a",
          "developer implement it."
        ))
      )
    )
  )
}
