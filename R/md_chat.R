# Floating AI chatbot bubble.
# UI is built with {shinychat}; responses come from {ellmer} + Claude.

md.chat_ui <- function() {
  shiny::tagList(
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
      shinychat::chat_ui("chat", height = "100%", width = "100%")
    ),
    shiny::tags$script(shiny::HTML("
      document.getElementById('chat-fab').addEventListener('click', function() {
        document.getElementById('chat-panel').classList.toggle('open');
      });
    "))
  )
}

md.chat_server <- function(input, output, session) {
  client <- ellmer::chat_anthropic(
    system_prompt = "You are a helpful assistant for the GBIF Dashboard, a Shiny
      app showing species occurrence data from GBIF. Keep answers concise."
  )

  shiny::observeEvent(input$chat_user_input, {
    stream <- client$stream_async(input$chat_user_input)
    shinychat::chat_append("chat", stream)
  })
}
