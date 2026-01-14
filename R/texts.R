mit_license_text <- shiny::tagList(
  shiny::p("Copyright (c) 2026 ShinyGBIF authors"),
  shiny::p(
    "Permission is hereby granted, free of charge, to any person obtaining a copy of this software
  and associated documentation files (the 'Software'), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge, publish, distribute,
  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:"
  ),
  shiny::p(
    "The above copyright notice and this permission notice shall be included in all copies or
    substantial portions of the Software."
  ),
  shiny::p(
    "THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
    BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
  )
)

info_text <- shiny::tagList(
  shiny::p(
    "This Shiny dashboard was developed as part of a home assignment for an R Shiny Developer role
    at Appsilon. The data provided is from",
    shiny::a("GBIF (Global Biodiversity Information Facility).", href = "https://www.gbif.org/")
  ),
  shiny::h5("Write later when the app is done!")
)
