
validateTheme <- function(theme, call = parent.frame()) {
  if (is.null(theme)) theme <- 'bslib::bs_theme()'
  keys <- names(omopViewerThemes)
  msg <- paste0(
    "theme must be a 'bslib::bs_theme()' character or a choice between: ",
    glue::glue_collapse(keys, sep = ", ", last = " or "), "."
  )
  omopgenerics::assertCharacter(theme, length = 1, call = call)
  if (theme %in% keys) {
    theme <- omopViewerThemes[[theme]]
  } else {
    isTheme <- tryCatch(
      bslib::is_bs_theme(rlang::eval_tidy(rlang::parse_expr(theme))),
      error = function(e) FALSE
    )
    if (!isTheme) {
      cli::cli_abort(message = msg, call = call)
    }
  }
  return(theme)
}
pageTheme <- function(theme) {
  if (is.null(theme)) return(character())
  return(paste0('theme = ', theme))
}
