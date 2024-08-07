#' Apply Filters to a Data Frame
#'
#' This function filters a data frame based on the specified columns and input values.
#'
#' @param df A data frame to be filtered.
#' @param input Shiny input object containing the filter values.
#' @param ns Namespace function for the module.
#' @param cols_to_filter A vector of column names to be filtered.
#'
#' @return A filtered data frame.
#'
#' @export
applyFilters <- function(df, input, ns, cols_to_filter) {
  for (col in cols_to_filter) {
    filter_values <- input[[ns(paste0(col, "_filter"))]]
    if (!is.null(filter_values) && length(filter_values) > 0) {
      df <- df |> dplyr::filter((!!rlang::sym(col)) %in% filter_values)
    }
  }
  df
}

#' Initialize Server Logic for Shiny Module
#'
#' This function initializes the server logic for a Shiny module that creates dynamic filters
#' and displays a filtered data table.
#'
#' @param id The module id.
#' @param dataset A reactive expression that returns the dataset to be used.
#' @param global_store A reactive value or function to store the unique result IDs.
#'
#' @export
filterSettingInitServer <- function(id, dataset, global_store) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Identify columns that have multiple unique values and exclude 'result_id' and 'cohort_definition_id'
    multi_value_cols <- shiny::reactive({
      df <- dataset()
      # Calculate which columns have more than one unique value
      valid_cols <- names(df)[sapply(df, function(x) length(unique(x)) > 1)]
      valid_cols#[!(valid_cols %in% c("result_id", "cohort_definition_id"))]
    })

    # Render dynamic filter UI based on the dataset columns with more than one unique value
    output$filter_ui <- shiny::renderUI({
      df <- dataset()  # Load data to generate filters
      shiny::fluidRow(
        lapply(multi_value_cols(), function(col) {
          shiny::selectInput(
            inputId = ns(paste0(col, "_filter")),
            label = paste("Filter by", col),
            choices = c("", unique(df[[col]])),  # Include an option to select no filter
            selected = unique(df[[col]])[1],
            multiple = TRUE
          )
        })
      )
    })

    # Reactive data based on input filters
    reactive_data <- shiny::reactive({
      df <- dataset()
      # Apply filters dynamically based on input selections
      applyFilters(df, input, ns, multi_value_cols())
    })

    # Store unique result_ids for later use
    unique_result_ids <- shiny::reactive({
      unique(reactive_data()$result_id)
    })

    # Save unique_result_ids in the global store
    shiny::observe({
      global_store(unique_result_ids())
    })

    # Display DataTable with all or filtered data
    output$statetable_setting <- DT::renderDT({
      DT::datatable(reactive_data(), extensions = 'Buttons', options = list(
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
        pageLength = 10
      ))
    })
  })
}

#' Table UI Function
#'
#' This function creates the UI for the Shiny module that includes dynamic filters and a data table.
#'
#' @param id The module id.
#' @export
filterSettingUi <- function(id) {
  ns <- shiny::NS(id)

  shiny::fluidPage(
    shiny::uiOutput(ns("filter_ui")),
    DT::DTOutput(ns("statetable_setting"))
  )
}
