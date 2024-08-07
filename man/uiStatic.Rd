% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ui.R
\name{uiStatic}
\alias{uiStatic}
\title{Provides the static UI of the shiny app for a given set of resultType(s).}
\usage{
uiStatic(data = omopgenerics::emptySummarisedResult(), asText = FALSE)
}
\arguments{
\item{data}{Summarised_result to build the shiny.}

\item{asText}{Whether to output a text object or to eval it.}
}
\value{
The ui of interest.
}
\description{
Provides the static UI of the shiny app for a given set of resultType(s).
}
