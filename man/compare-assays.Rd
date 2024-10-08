% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plots_compare_assays.R
\name{plotCompareAssays}
\alias{plotCompareAssays}
\title{Compare two assays}
\usage{
plotCompareAssays(
  obj,
  i,
  j,
  info = NULL,
  pal.name = NULL,
  subset.view = NULL,
  n = 100,
  type = "scatter",
  FUN = NULL
)
}
\arguments{
\item{obj}{An instance of the class \code{omXplore}.}

\item{i}{A numeric matrix containing quantitative data after
normalization.}

\item{j}{A numeric matrix containing quantitative data after
normalization}

\item{info}{xxx}

\item{pal.name}{xxx}

\item{subset.view}{xxx}

\item{n}{xxx}

\item{type}{The type of plot. Available values are 'scatter' (default)
or 'line'}

\item{FUN}{xxx}
}
\value{
A plot
}
\description{
This plot compares the quantitative proteomics data between two assays.
It can be used for example to compare the effect of the normalization
process.

The comparison is made with the division operator.
}
\examples{
data(vData_ft)
plotCompareAssays(vData_ft, 1, 2, n = 5)

}
\author{
Samuel Wieczorek, Enora Fremy
}
