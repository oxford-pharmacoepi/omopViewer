test_that("background", {
  #tdir <- here::here()
  tdir <- tempdir()
  expect_no_error(exportStaticApp(
    result = emptySummarisedResult(),
    directory = tdir,
    background = TRUE
  ))
  unlink(file.path(tdir, "shiny"), recursive = TRUE)
  expect_no_error(exportStaticApp(
    result = emptySummarisedResult(),
    directory = tdir,
    background = FALSE
  ))
  unlink(file.path(tdir, "shiny"), recursive = TRUE)

  expect_snapshot(createBackground(TRUE) |> cat(sep = "\n"))

  expect_snapshot(createBackground(FALSE) |> cat(sep = "\n"))
})
