% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_Filtering.R
\name{mod_filtering}
\alias{mod_filtering}
\alias{mod_Filtering_ui}
\alias{mod_Filtering_server}
\title{Module Filtering}
\usage{
mod_Filtering_ui(id)

mod_Filtering_server(
  id,
  dataIn = reactive({
     NULL
 }),
  steps.enabled = reactive({
     NULL
 }),
  remoteReset = reactive({
     FALSE
 }),
  steps.status = reactive({
     NULL
 }),
  current.pos = reactive({
     1
 }),
  verbose = FALSE
)
}
\arguments{
\item{id}{A \code{character(1)} which is the 'id' of the module.}

\item{dataIn}{An instance of the class \code{QFeatures}}

\item{steps.enabled}{A \code{logical()} which indicates whether each step is
enabled or disabled in the UI.}

\item{remoteReset}{A \code{logical(1)} which acts asa a remote command to reset
the module to its default values. Default is FALSE.}

\item{steps.status}{A \code{logical()} which indicates the status of each step
which can be either 'validated', 'undone' or 'skipped'.
enabled or disabled in the UI.}

\item{current.pos}{A \code{interger(1)} which acts as a remote command to make
a step active in the timeline. Default is 1.}

\item{verbose}{A \code{logical(1)} to indicates whether run and debug infos must
be printed in the console. Default is FALSE.}
}
\value{
NA
}
\description{
xxxxx
}
\section{Step 'Quanti metadata filtering'}{


xxxxxxx
}

\section{Step 'Variable filtering'}{


xxxxx
}

\section{Step 'Save'}{


xxxxxx
}

\examples{
\dontshow{if () (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
shiny::runApp(workflowApp("Filtering", verbose = TRUE)
\dontshow{\}) # examplesIf}
}
\seealso{
The user manual of the package \code{MagellanNTK}.
}
