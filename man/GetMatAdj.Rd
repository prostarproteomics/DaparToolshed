% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_DAPAR.R
\name{GetMatAdj}
\alias{GetMatAdj}
\title{Returns the contains of the slot processing  of an object of
class \code{MSnSet}}
\usage{
GetMatAdj(obj)
}
\arguments{
\item{obj}{An object (peptides) of class \code{MSnSet}.}
}
\value{
The slot processing of obj@processingData
}
\description{
Returns the contains of the slot processing  of an object of
class \code{MSnSet}
}
\examples{
data(Exp1_R25_pept, package="DAPARdata")
Xshared <- BuildAdjacencyMatrix(Exp1_R25_pept[seq_len(100)], 
"Protein_group_IDs", FALSE)
Xunique <- BuildAdjacencyMatrix(Exp1_R25_pept[seq_len(100)], 
"Protein_group_IDs", TRUE)
ll.X <- list(matWithSharedPeptides = Xshared, 
matWithUniquePeptides = Xunique)
Exp1_R25_pept <- SetMatAdj(Exp1_R25_pept, ll.X)
ll.X <- GetMatAdj(Exp1_R25_pept)

}
\author{
Samuel Wieczorek
}
