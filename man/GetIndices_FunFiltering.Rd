% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/funcs_FunctionFiltering.R
\name{GetIndices_FunFiltering}
\alias{GetIndices_FunFiltering}
\title{Delete the lines in the matrix of intensities and the metadata table
given their indices.}
\usage{
GetIndices_FunFiltering(
  obj,
  conds,
  level,
  pattern = NULL,
  type = NULL,
  percent,
  op,
  th
)
}
\arguments{
\item{obj}{An object of class \code{SummarizedExperiment} containing
quantitative data.}

\item{conds}{xxx}

\item{level}{A vector of integers which are the indices of lines to
delete.}

\item{pattern}{A string to be included in the \code{SummarizedExperiment}
object for log.}

\item{type}{xxx}

\item{percent}{xxx}

\item{op}{xxx}

\item{th}{xxx}
}
\value{
An instance of class \code{SummarizedExperiment} that have been filtered.
}
\description{
Delete the lines in the matrix of intensities and the metadata table
given their indices.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
NA
\dontshow{\}) # examplesIf}
}
\author{
Samuel Wieczorek
}
