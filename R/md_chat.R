# Floating AI chatbot bubble.
# UI is built with {shinychat}; responses come from {ellmer} + Claude.
#
# Flow: click the bubble -> pick one of three request categories ->
# the actual chat is revealed, with a system prompt tailored to that category.

chat_categories <- list(
  explore = list(
    label = "New features",
    icon = "tools",
    greeting = "Great! What new feature do you want to have in GBIF app?",
    prompt = "You are responsible for building new features for GBIF Dashboard. The user wants to
    add features that would help him to achieve his goals."
  ),
  species = list(
    label = "UI changes",
    icon = "stars",
    greeting = "Sure! Which UI changes do you want me to do?",
    prompt = "You are responsible for changing the UI elements of the GBIF Dashboard. The user wants
    to make the app more pleasant, easier to use and better to visualize. Changes need to be concise
    with the rest of the untouched UI elements."
  ),
  help = list(
    label = "Bug fixes",
    icon = "bug-fill",
    greeting = "Happy to help! Please provide a detailed description of the bug and what is the
    expected behaviour.",
    prompt = "You are an developer that just do bug fixes for GBIF Dashboard. The user
    spotted something that he thinks it was not supposed to happen in the app. Verify the code to
    see if what the user claims actually is the expected behaviour for the app. If it's not, fix the
    bug with the user's requirements."
  )
)

md.chat_ui <- function() {
  category_button <- function(key) {
    cat <- chat_categories[[key]]
    shiny::tags$button(
      class = "chat-cat",
      type = "button",
      `data-cat` = key,
      bsicons::bs_icon(cat$icon, size = "1.2em"),
      shiny::span(cat$label)
    )
  }

  shiny::tagList(
    shiny::tags$head(
      shiny::tags$link(rel = "stylesheet", type = "text/css", href = "dir/css/chatbot.css")
    ),
    shiny::uiOutput("chat_notification"),
    shiny::tags$button(
      id = "chat-fab",
      class = "chat-fab",
      type = "button",
      `aria-label` = "Open AI assistant",
      bsicons::bs_icon("chat-dots-fill", size = "1.6em")
    ),
    shiny::div(
      id = "chat-panel",
      class = "chat-panel",
      shiny::div(
        id = "chat-menu",
        class = "chat-menu",
        shiny::div(class = "chat-menu-title", "Which part of the app you want to work on?"),
        purrr::map(names(chat_categories), category_button)
      ),
      shiny::div(
        id = "chat-view",
        class = "chat-view",
        shiny::div(
          class = "chat-view-header",
          shiny::tags$button(
            id = "chat-back",
            class = "chat-back",
            type = "button",
            `aria-label` = "Back to selection",
            bsicons::bs_icon("arrow-left"),
            shiny::span("Back")
          )
        ),
        shiny::div(
          class = "chat-view-body",
          shinychat::chat_ui("chat", height = "100%", width = "100%")
        )
      )
    ),
    shiny::tags$script(shiny::HTML("
      document.addEventListener('click', function(e) {
        if (e.target.closest('#chat-fab')) {
          document.getElementById('chat-panel').classList.toggle('open');
          return;
        }
        if (e.target.closest('#chat-back')) {
          document.getElementById('chat-view').style.display = 'none';
          document.getElementById('chat-menu').style.display = 'flex';
          return;
        }
        var btn = e.target.closest('.chat-cat');
        if (btn) {
          document.getElementById('chat-menu').style.display = 'none';
          document.getElementById('chat-view').style.display = 'flex';
          Shiny.setInputValue('chat_category', btn.dataset.cat, {priority: 'event'});
        }
      });
    "))
  )
}

# Confirmation dialog shown before any issue is opened.
chat_confirm_modal <- function(title, body) {
  shiny::modalDialog(
    title = "Confirm this suggestion",
    easyClose = FALSE,
    shiny::tags$p("The following issue will be opened for the development team:"),
    shiny::tags$h5(title),
    shiny::tags$pre(
      style = "white-space: pre-wrap; max-height: 300px; overflow: auto;",
      body
    ),
    footer = shiny::tagList(
      shiny::actionButton("chat_issue_cancel", "Cancel"),
      shiny::actionButton("chat_issue_confirm", "Confirm & open issue", class = "btn-success")
    )
  )
}

# iPhone-style banner shown while the preview is being deployed.
chat_loading <- function() {
  shiny::div(
    id = "chat-loading",
    class = "chat-notif chat-loading",
    shiny::div(class = "chat-notif-icon", shiny::div(class = "chat-spinner")),
    shiny::div(
      class = "chat-notif-text",
      shiny::div(class = "chat-notif-title", "Deploying your preview…"),
      shiny::div(class = "chat-notif-body", "This can take a few minutes — I'll let you know when it's ready.")
    )
  )
}

# iPhone-style notification shown when the deployment link is ready.
# The whole banner is a link: clicking it opens the preview and dismisses it.
chat_notification <- function(link) {
  shiny::a(
    id = "chat-notif",
    class = "chat-notif",
    href = link,
    target = "_blank",
    onclick = "Shiny.setInputValue('chat_notification_dismiss', Math.random(), {priority: 'event'});",
    shiny::div(class = "chat-notif-icon", bsicons::bs_icon("rocket-takeoff-fill")),
    shiny::div(
      class = "chat-notif-text",
      shiny::div(class = "chat-notif-title", "Deployment ready"),
      shiny::div(class = "chat-notif-body", link)
    )
  )
}

md.chat_server <- function(input, output, session) {
  client <- shiny::reactiveVal(NULL)
  current_cat <- shiny::reactiveVal(NULL)
  staged_issue <- shiny::reactiveVal(NULL)
  tracked_issue <- shiny::reactiveVal(NULL)
  notification_link <- shiny::reactiveVal(NULL)
  poll_attempts <- 0

  # Top banner: a spinner while deploying, then the deployment-ready link.
  output$chat_notification <- shiny::renderUI({
    if (!is.null(notification_link())) return(chat_notification(notification_link()))
    if (!is.null(tracked_issue())) return(chat_loading())
    NULL
  })

  # The banner only disappears when the user clicks it.
  shiny::observeEvent(input$chat_notification_dismiss, {
    notification_link(NULL)
  })

  # Called by the `propose_issue` tool: stage the issue and ask the user to
  # confirm before anything is opened on GitHub.
  propose <- function(title, body) {
    staged_issue(list(title = title, body = body))
    shiny::showModal(chat_confirm_modal(title, body), session = session)
    paste(
      "A confirmation dialog summarising the issue has been shown to the user.",
      "Wait for their decision; do not take any further action."
    )
  }

  shiny::observeEvent(input$chat_category, {
    cat_key <- input$chat_category
    cat <- chat_categories[[cat_key]]
    shiny::req(cat)

    # Returning to the same category keeps the existing conversation intact.
    if (identical(current_cat(), cat_key)) return()

    current_cat(cat_key)
    shinychat::chat_clear("chat")
    chat_client <- ellmer::chat_anthropic(
      system_prompt = paste(cat$prompt, chat_issue_instructions)
    )
    chat_client$register_tools(gh.chat_tools(propose))
    client(chat_client)
    shinychat::chat_append("chat", cat$greeting)
  })

  shiny::observeEvent(input$chat_user_input, {
    shiny::req(client())
    stream <- client()$stream_async(input$chat_user_input)
    shinychat::chat_append("chat", stream)
  })

  shiny::observeEvent(input$chat_issue_confirm, {
    issue <- staged_issue()
    shiny::req(issue)
    staged_issue(NULL)
    shiny::removeModal()
    shinychat::chat_append("chat", "Opening the issue…")

    res <- gh.open_issue(issue$title, issue$body)
    if (isTRUE(res$ok)) {
      shinychat::chat_append("chat", paste0(
        "Issue opened: ", res$url,
        "\n\nAn AI agent will now implement it and deploy a preview. ",
        "I'll post the deployment link here as soon as it's ready…"
      ))
      poll_attempts <<- 0
      tracked_issue(res$number)
    } else {
      shinychat::chat_append("chat", paste0("Failed to open the issue: ", res$message))
    }
  })

  shiny::observeEvent(input$chat_issue_cancel, {
    staged_issue(NULL)
    shiny::removeModal()
    shinychat::chat_append("chat", "Okay, I discarded the suggestion. Let me know how you'd like to adjust it.")
  })

  # Poll the issue's linked PR until its "Deployment link" section appears.
  shiny::observe({
    num <- tracked_issue()
    if (is.null(num)) return()

    shiny::invalidateLater(15000)
    poll_attempts <<- poll_attempts + 1

    link <- gh.deployment_link(num)
    if (!is.na(link)) {
      # Stop polling until the user opens a new issue, then show the banner.
      tracked_issue(NULL)
      shinychat::chat_append("chat", paste0(
        "🚀 Your suggestion has been deployed! Preview it here: ", link
      ))
      notification_link(link)
    } else if (poll_attempts >= 40) {
      tracked_issue(NULL)
      shinychat::chat_append("chat", paste(
        "I haven't spotted the deployment link yet — it may still be building.",
        "Check the 'Deployment link' section of the issue's linked PR."
      ))
    }
  })
}
