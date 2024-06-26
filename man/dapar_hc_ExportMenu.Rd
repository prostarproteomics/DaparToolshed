% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_DAPAR.R
\name{dapar_hc_ExportMenu}
\alias{dapar_hc_ExportMenu}
\title{Customised contextual menu of highcharts plots}
\usage{
dapar_hc_ExportMenu(hc, filename)
}
\arguments{
\item{hc}{A highcharter object}

\item{filename}{The filename under which the plot has to be saved}
}
\value{
A contextual menu for highcharts plots
}
\description{
Customised contextual menu of highcharts plots
}
\examples{
library("highcharter")
hc <- highchart()
hc_chart(hc, type = "line")
hc_add_series(hc, data = c(29, 71, 40))
dapar_hc_ExportMenu(hc, filename = "foo")

}
\author{
Samuel Wieczorek
}
