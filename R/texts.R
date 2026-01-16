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
    shiny::a("GBIF (Global Biodiversity Information Facility).", href = "https://www.gbif.org/"),
    "\n There are a lot of data that is labeled as 'unknown', 'undetermined' or not available."
  ),
  shiny::h5("How to read this dashboard"),
  shiny::p(
    "In the navbar are the virtual select inputs for you to choose a species, at least one continent
    and at least one country. The species input always has one selected, and if no continent or no
    country is selected, the cards (except for the map) will show a message requiring that you
    select a continent or a country."
  ),
  shiny::p(
    "The valueboxes shows information about the total of observations, the sex distribution and
    which kingdom and family the species belongs to."
  ),
  shiny::p(
    "The two bar plots show the ranking of life stage and location observations frequency."
  ),
  shiny::p(
    "The timeline plot shows the observations frequency through the years, or grouped by months or
    hours. You can select what kind of group by you want throught the card sidebar."
  ),
  shiny::p(
    "Finally, the map shows the heat frequency of an species in locations that it was observed.
    If the zoom in too far, it shows the data as a heat map. \n If the zoom is too close, the heat
    turns into circle marks, representing each observation. When you click in a circle amrk, a popup
    appears with data about that observation."
  ),
  shiny::h5("About the development"),
  bslib::accordion_panel(
    "The data",
    shiny::p(
      "The assignment requires that we use just the Poland data. But, as a brazilian, I will use our
    data too. Although the extra assignment says that using data beyond Poland is a check, I can't
    say that this extra data was a great work of performance improvement. \n However, the app runs
    fast and fine."
    ),
  ),
  bslib::accordion_panel(
    "The map",
    shiny::p(
      "Normally, I would use the ",
      shiny::a("{leaflet} package", href = "https://rstudio.github.io/leaflet/"),
      "in my current job. But, for this assignment, I take the risk and tested a different map source
    that I saw in an R blog's article. <br> The package is the ",
      shiny::a("{mapgl} package, ", href = "https://walker-data.com/mapgl/"),
      "created by the writer of the article that I read before, Kyle Walker. Here the ",
      shiny::a("post's link.", href = "https://walker-data.com/posts/mapgl-dots/"),
      "\n It is interesting how he combine the heat map and the circle cluster map. Due to the
    short time, I consulted LLM Claude Sonnet 4.5 to make the map."
    ),
  ),
  bslib::accordion_panel(
    "The plots",
    shiny::p(
      "All of the plots in the dashboards and reports of my job are maed with ",
      shiny::a("{echarts4r} package.", href = "https://echarts4r.john-coene.com/"),
      "<br> It is excellent for easy customization, and has good interactive features that our
    customers like a lot. <br>",
      shiny::a("And is fast!", href = "https://www.appsilon.com/post/shiny-app-performance-fix"),
    ),
  )
)
