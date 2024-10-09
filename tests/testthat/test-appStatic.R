test_that("logo", {
  #tdir <- here::here()
  tdir <- tempdir()

  # test no logo
  expect_no_error(exportStaticApp(
    result = emptySummarisedResult(), directory = tdir, logo = NULL
  ))
  expect_true("shiny" %in% list.files(tdir))
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # test keywords
  for (key in logoKeywords) {
    expect_identical(basename(logoPath(key)), paste0(key, "_logo.svg"))
    expect_no_error(exportStaticApp(result = emptySummarisedResult(),directory = tdir, logo = key))
    expect_true("shiny" %in% list.files(tdir))
    unlink(file.path(tdir, "shiny"), recursive = TRUE)
  }

  # custom logo
  expect_no_error(exportStaticApp(result = emptySummarisedResult(),
                                  directory = tdir, logo = here::here("inst", "oxford.png")))
  expect_true("shiny" %in% list.files(tdir))
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # test generated ui
  expect_snapshot(uiStatic(logo = "my_pic.png") |> cat(sep = "\n"))
})

test_that("empty shiny", {
  #tdir <- here::here()
  tdir <- tempdir()
  expect_no_error(exportStaticApp(result = emptySummarisedResult(),directory = tdir))
  expect_true("shiny" %in% list.files(tdir))
  expect_snapshot(uiStatic() |> cat(sep = "\n"))
  expect_snapshot(serverStatic() |> cat(sep = "\n"))
  unlink(file.path(tdir, "shiny"), recursive = TRUE)
})

test_that("CohortCharacteristics shiny", {
  # create mock cdm
  set.seed(123456)
  cdm <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence(recordPerson = 3) |>
    omock::mockDrugExposure(recordPerson = 4.5) |>
    omock::mockCohort(
      numberCohorts = 3, cohortName = c("covid", "tb", "asthma"))

  # TO BE REMOVED WHEN CohortCharacteristics works with local cdms
  cdm <- CDMConnector::copyCdmTo(
    con = duckdb::dbConnect(duckdb::duckdb()), cdm = cdm, schema = "main")

  # generate result set
  result <- omopgenerics::bind(
    cdm$cohort |>
      CohortCharacteristics::summariseCharacteristics(),
    cdm$cohort |>
      CohortCharacteristics::summariseCohortAttrition(),
    cdm$cohort |>
      CohortCharacteristics::summariseCohortCount(),
    cdm$cohort |>
      CohortCharacteristics::summariseCohortOverlap(),
    cdm$cohort |>
      CohortCharacteristics::summariseCohortTiming(),
    cdm$cohort |>
      PatientProfiles::addAge(ageGroup = list(c(0, 44), c(45, Inf))) |>
      PatientProfiles::addSex(name = "cohort") |>
      CohortCharacteristics::summariseLargeScaleCharacteristics(
        strata = list("sex", "age_group", c("age_group", "sex")),
        eventInWindow = "condition_occurrence",
        episodeInWindow = "drug_exposure"
      )
  )

  # generate shiny
  tdir <- tempdir()
  expect_no_error(exportStaticApp(result = result, directory = tdir, summary = FALSE))
  expect_true("shiny" %in% list.files(tdir))

  # test ui snapshot
  ui <- readLines(file.path(tdir, "shiny", "ui.R"))
  expect_snapshot(cat(ui, sep = "\n"))

  # test server snapshot
  server <- readLines(file.path(tdir, "shiny", "server.R"))
  expect_snapshot(cat(server, sep = "\n"))

  # test global snapshot
  global <- readLines(file.path(tdir, "shiny", "global.R"))
  expect_snapshot(cat(global, sep = "\n"))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # test summary = FALSE
  expect_no_error(exportStaticApp(result = result, directory = tdir, summary = FALSE))
  expect_true("shiny" %in% list.files(tdir))

  # test ui snapshot
  ui <- readLines(file.path(tdir, "shiny", "ui.R"))
  expect_snapshot(cat(ui, sep = "\n"))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  PatientProfiles::mockDisconnect(cdm)
})

test_that("title", {
  #tdir <- here::here()
  tdir <- tempdir()
  expect_no_error(exportStaticApp(
    result = emptySummarisedResult(), directory = tdir, title = "example"
  ))

  # check shiny is created
  expect_true("shiny" %in% list.files(tdir))

  # snapshot for ui
  ui <- readLines(file.path(tdir, "shiny", "ui.R"))
  expect_snapshot(cat(ui, sep = "\n"))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

})

test_that("order tabs", {
  # create mock cdm
  set.seed(123456)
  cdm <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence(recordPerson = 3) |>
    omock::mockDrugExposure(recordPerson = 4.5) |>
    omock::mockCohort(
      numberCohorts = 3, cohortName = c("covid", "tb", "asthma"))

  # TO BE REMOVED WHEN CohortCharacteristics works with local cdms
  cdm <- CDMConnector::copyCdmTo(
    con = duckdb::dbConnect(duckdb::duckdb()), cdm = cdm, schema = "main")

  # generate result set
  result <- omopgenerics::bind(
    cdm$cohort |>
      CohortCharacteristics::summariseCohortAttrition(),
    cdm$cohort |>
      CohortCharacteristics::summariseCohortCount(),
    cdm$cohort |>
      CohortCharacteristics::summariseCohortOverlap()
  )

  # generate shiny
  tdir <- tempdir()
  expect_no_error(exportStaticApp(
    result = result,
    directory = tdir,
    panels = list(
      "summarise_cohort_count",
      "summarise_cohort_overlap",
      "summarise_cohort_attrition"
    )
  ))

  # snapshot ui
  ui <- readLines(file.path(tdir, "shiny", "ui.R"))
  expect_snapshot(cat(ui, sep = "\n"))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # expect warning if panel is not present
  expect_warning(exportStaticApp(
    result = result,
    directory = tdir,
    panels = list(
      "summarise_cohort_count", "summarise_cohort_attrition",
      "summarise_cohort_overlap", "not an option",
      "another missing result"
    )
  ))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # expect warning if panel is not present
  expect_warning(exportStaticApp(
    result = result, directory = tdir, panels = list("not an option")
  ))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # menu with results not in result
  expect_warning(exportStaticApp(
    result = result,
    directory = tdir,
    panels = list(
      "CHARACTERISTICS" = c("summarise_characteristics", "summarise_large_scale_characteristics", "hi"),
      "summarise_cohort_overlap"
    )
  ))

  # snapshot ui
  ui <- readLines(file.path(tdir, "shiny", "ui.R"))
  expect_snapshot(cat(ui, sep = "\n"))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # menu for details
  expect_no_error(exportStaticApp(
    result = result,
    directory = tdir,
    panels = list(
      "DETAILS" = c("summarise_cohort_count", "Attrition" = "summarise_cohort_attrition"),
      "Overlap" = "summarise_cohort_overlap"
    )
  ))

  # snapshot ui
  ui <- readLines(file.path(tdir, "shiny", "ui.R"))
  expect_snapshot(cat(ui, sep = "\n"))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # expect error if it is not a list
  expect_error(exportStaticApp(result = result, panels = c("must be a list")))

  # expect error if duplicated elements
  expect_error(exportStaticApp(result = result, panels = list(
    "summarise_cohort_overlap", "summarise_cohort_overlap")))
})

test_that("theme", {
  #tdir <- here::here()
  tdir <- tempdir()

  expect_no_error(exportStaticApp(result = emptySummarisedResult(), directory = tdir, theme = "theme1", open = FALSE))

  ui <- readLines(file.path(tdir, "shiny", "ui.R")) |>
    stringr::str_flatten() |>
    stringr::str_replace_all(" ", "") |>
    stringr::str_replace_all('"', "'")

  expectedTheme <- omopViewerThemes$theme1 |>
    stringr::str_replace_all("\n| ", "") |>
    stringr::str_replace_all('"', "'")

  expect_true(grepl(expectedTheme, ui, fixed = TRUE))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  # custom theme
  theme <- "bslib::bs_theme(bootswatch = 'sandstone',
    primary = '#605ca8',
    bg = 'white',
    fg = 'black',
    success = '#3B9AB2',
    base_font = bslib::font_google('Space Mono'),
    code_font = bslib::font_google('Space Mono'))"

  expect_message(exportStaticApp(
    result = emptySummarisedResult(),
    theme = theme,
    directory = tdir,
    open = FALSE
  ))

  ui <- readLines(file.path(tdir, "shiny", "ui.R")) |>
    stringr::str_flatten() |>
    stringr::str_replace_all(" ", "") |>
    stringr::str_replace_all('"', "'")

  expectedTheme <- theme |>
    stringr::str_replace_all("\n| ", "") |>
    stringr::str_replace_all('"', "'")

  expect_true(grepl(expectedTheme, ui, fixed = TRUE))

  # delete created shiny
  unlink(file.path(tdir, "shiny"), recursive = TRUE)
})

