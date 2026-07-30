# Floating AI chatbot bubble.
# UI is built with {shinychat}; responses come from {ellmer} + Claude.
#
# Flow: click the bubble -> pick one of three request categories ->
# the actual chat is revealed, with a system prompt tailored to that category.

chat_categories <- list(
  explore = list(
    label = "Explore the data",
    icon = "bar-chart-fill",
    greeting = "Great! Ask me anything about the observations, counts and distributions on the dashboard.",
    prompt = "You are the assistant for the GBIF Dashboard, a Shiny app showing
      species occurrence data from GBIF. The user wants to explore and understand
      the data (observation counts, sex and life-stage distributions, countries,
      continents, trends). Give concise, data-focused answers."
  ),
  species = list(
    label = "Species information",
    icon = "bug-fill",
    greeting = "Sure! Which species would you like to know more about?",
    prompt = "You are the assistant for the GBIF Dashboard. The user wants general
      biological information about species (taxonomy, habitat, behaviour,
      conservation status). Give concise, accurate answers."
  ),
  help = list(
    label = "How to use the dashboard",
    icon = "question-circle-fill",
    greeting = "Happy to help! What would you like to know about using the dashboard?",
    prompt = "You are the assistant for the GBIF Dashboard, a Shiny app. The user
      needs help using the dashboard: selecting a species, continents and
      countries in the navbar, and reading the value boxes, rankings, timeline and
      map. Give concise, step-by-step guidance."
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
        shiny::div(class = "chat-menu-title", "How can I help you?"),
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

md.chat_server <- function(input, output, session) {
  client <- shiny::reactiveVal(NULL)
  current_cat <- shiny::reactiveVal(NULL)

  shiny::observeEvent(input$chat_category, {
    cat_key <- input$chat_category
    cat <- chat_categories[[cat_key]]
    shiny::req(cat)

    # Returning to the same category keeps the existing conversation intact.
    if (identical(current_cat(), cat_key)) return()

    current_cat(cat_key)
    shinychat::chat_clear("chat")
    client(ellmer::chat_anthropic(system_prompt = cat$prompt))
    shinychat::chat_append("chat", cat$greeting)
  })

  shiny::observeEvent(input$chat_user_input, {
    shiny::req(client())
    stream <- client()$stream_async(input$chat_user_input)
    shinychat::chat_append("chat", stream)
  })
}
