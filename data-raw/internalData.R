
# you need to load the package before running these lines of code as styleCode()
# is required.

# to search icons see: https://fontawesome.com/search?m=free&o=r

omopViewerTabs <- dplyr::tribble(
  ~result_tab_id, ~result_type, ~package, ~title, ~icon, ~information,
  1L, "summarise_cohort_overlap", "CohortCharacteristics", "Cohort overlap", "circle-half-stroke", "Cohort overlap shows the number of subjects that contribute to a pair of cohorts.",
  2L, "summarise_cohort_attrition", "CohortCharacteristics", "Cohort Attrition", "layer-group", "",
  3L, "summarise_cohort_timing", "CohortCharacteristics", "Cohort timing", "chart-simple", "",
  4L, "summarise_characteristics", "CohortCharacteristics", "Cohort characteristics", "users-gear", "",
  5L, "summarise_cohort_count", "CohortCharacteristics", "Cohort count", "users", "",
  6L, "summarise_large_scale_characteristics", "CohortCharacteristics", "Large Scale Characteristics", "arrow-up-right-dots", ""
)

omopViewerPlots <- dplyr::tribble(
  ~plot_id, ~result_tab_id, ~title, ~fun, ~output,
  1L, 1L, "Plot cohort overlap", "plotCohortOverlap", "ggplot2",
  2L, 2L, "Diagram", "plotCohortAttrition", "grViz",
  3L, 3L, "Plot cohort timing", "plotCohortTiming", "ggplot2",
  4L, 4L, "Plot characteristics", "plotCharacteristics", "ggplot2",
  5L, 5L, "Plot cohort count", "plotCohortCount", "ggplot2"
)

omopViewerPlotArguments <- dplyr::tribble(
  ~plot_id, ~argument, ~type, ~opts, ~multiple,
  1L, "facet", "selector", "<grouping>, <variable>, <settings>", TRUE,
  1L, "uniqueCombinations", "check", "", NA,
  3L, "plotType", "selector", "boxplot, density", FALSE,
  3L, "timeScale", "selector", "days, years", FALSE,
  3L, "facet", "selector", "<grouping>, <variable>, <settings>", TRUE,
  3L, "colour", "selector", "<grouping>, <variable>, <settings>", TRUE,
  3L, "uniqueCombinations", "check", "", NA,
  4L, "plotStyle", "selector", "boxplot, barplot, scatterplot", FALSE,
  4L, "facet", "selector", "<grouping>, <variable>, <settings>", TRUE,
  4L, "colour", "selector", "<grouping>, <variable>, <settings>", TRUE,
  5L, "facet", "selector", "<grouping>, <variable>", TRUE,
  5L, "colour", "selector", "<grouping>, <variable>", TRUE,
)

omopViewerProj <- c(
  "Version: 1.0", "", "RestoreWorkspace: Default", "SaveWorkspace: Default",
  "AlwaysSaveHistory: Default", "", "EnableCodeIndexing: Yes",
  "UseSpacesForTab: Yes", "NumSpacesForTab: 2", "Encoding: UTF-8", "",
  "RnwWeave: Sweave", "LaTeX: pdfLaTeX"
)

omopViewerGlobal <- c(
  "data <- omopViewer::importSummarisedResult(here::here(\"data\")) |>",
  "omopViewer::correctSettings()"
) |>
  styleCode()

# TO ADD NEW LOGOS YOU HAVE TO ADD THEM IN THIS LIST AND IN `inst/logos/`
# FOLLOW THIS NAMING: '{keyword}_logo.svg'
# NOTE IT IS NOT CASE SENSITIVE
logoKeywords <- c("hds", "ohdsi") |>
  stringr::str_to_lower()

backgroundKeywords <- dplyr::tribble(
  ~keyword, ~fun, ~link,
  "header", "bslib::card_header", "https://rstudio.github.io/bslib//reference/card_body.html",
  "footer", "bslib::card_footer", "https://rstudio.github.io/bslib//reference/card_body.html"
)

omopViewerThemes <- list(
  theme1 = "bslib::bs_theme(
    bootswatch = 'sandstone',
    primary = '#605ca8',
    bg = 'white',
    fg = 'black',
    success = '#3B9AB2',
    base_font = bslib::font_google('Space Mono'),
    code_font = bslib::font_google('Space Mono')
  )"
)

usethis::use_data(
  omopViewerTabs, omopViewerPlots, omopViewerPlotArguments, omopViewerProj,
  omopViewerGlobal, logoKeywords, backgroundKeywords, omopViewerThemes,
  overwrite = TRUE, internal = TRUE)

