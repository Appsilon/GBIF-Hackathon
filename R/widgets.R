wd.virtual_select_input <- function(
    inputId,
    label = NULL,
    searchPlaceholderText = NULL,
    multiple = FALSE,
    width = "auto"
) {
  shinyWidgets::virtualSelectInput(
    inputId = inputId,
    label = label,
    searchPlaceholderText = searchPlaceholderText,
    multiple = multiple,
    width = width,
    choices = NULL,
    dropboxWrapper = "body",
    hideClearButton = TRUE,
    optionsCount = 7,
    search = TRUE,
    searchNormalize = TRUE,
    showSelectedOptionsFirst = TRUE
  )
}
