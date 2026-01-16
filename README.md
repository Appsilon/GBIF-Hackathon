# Shiny App Dashboard for GBIF Observations

This Shiny app was developed as part of a home assignment for an R Shiny Developer role at Appsilon. The data provided is from [GBIF \| Global Biodiversity Information Facility](https://www.gbif.org/).

The Shiny app was built in an R Package structure, as taught in the book [R Packages (2e)](https://r-pkgs.org/). This is the structure that I am familiar with, since it is what we use in my current job to develop Shiny apps.

[Click here]() or in the link available in this repository details section to access the latest version of the dashboard.

## File structure

This Shiny app was built as an R Package. So, there are specific directories for almost every file.

In `R/` directory, there are all the scripts that will be loaded with the app:

- The `run_app.R` file contains the function that runs the app. Everything starts here;
- The `ui.R` and `server.R` are the main UI and Server modules;
- The `md_*.R` files are the Shiny Modules of the app;
- The `tidying_data.R` and `utils.R` contains the functions used to tidy data;
- The `plot.R` and `widgets.R` stores the functions that manipulates or creates UI elements;
- The `texts.R` stores HTML texts that fills the info modal and the license modal in the app.

In `data/` directory are stored the data frames used in this app and available on the package, like the famous `mtcars` and `palmerpeguins` (>= R 4.5) on base R.

In `man/` directory, there are the documentation files. I didn't generate them, but it can be generate using Roxygen2 tags.

In `tidy_rawdata/` file are the script used to process the raw database used in this app.

In `inst/` directory are stored the files used for UI purposes, like the logo and the css file.

## How to build

First, clone the `master` branch of this repository.

``` bash
git clone https://github.com/LKamogawa/ShinyGBIF.git
```

Then, if you are using RStudio, open the `.Rproj` file.

If you are using Positron, just open the project's file (the root directory, where the `.Rproj` is located).

Load all the package files with the `devtools::load_all(".")` function (or with `Ctrl/Cmd + Shift + L` shortcut command).

``` r
devtools::load_all(".")
```

You will need to install the R packages listed in `Depends` and `Imports` on the `DESCRIPTION` file. Also, this file states that you need the version `>= 4.5` of R to run the Shiny app.

After installing all the packages, restart R, run `devtools::load_all(".")` and run `run_app()` to start the app!

## Extras assignments

### Beautiful UI skill

I made some UI customization using `{bslib}` functions and a css file. I used the colours guidelines from GBIF brand. It is available on their [website](https://www.gbif.org/logos), where they have the image files for their logos too.

For the plots, I like the style of echarts' charts (and it is the main plot library that I use), so I sticked with it.

### Performance optimization skill

The main task requires that we use just the Poland data. But, as a Brazilian, I used our data too. Although the extra assignment says that using data beyond Poland is a check, I can't say that this extra data was a great work of performance improvement.

However, the app runs fast and fine. And I want to improve myself too!

Normally, in my job, we handle large data with SQL database engine hosted in Amazon AWS. But for this app, I can't use it. I've read about the `{arrow}` package and parquet files, but I will try it in another opportunity.

### JavaScript skill

The main JS skills that I have is when making very customized echarts plots. In this app, I didn't use it. I  the map plot you will see a huge HTML/JS script, but it was made with the help of LLM Claude Sonnet 4.5.

So it don't count, I guess.

### Infrastructure skill

Didn't check this.
