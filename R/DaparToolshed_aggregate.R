##' @title Aggregate an assay of peptides into proteins.
##' 
##' @description 
##' 
##' This function is a wrapper for the function [QFeatures::aggregateFeatures()].
##' It just add some meta informations to the aggregated assay, specific to
##' DaparToolshed and implement methods to aggregate the quantitative
##' metadata.
#' 
##' @title Aggregate an assay's quantitative features
##'
##' @description
##'
##' This function aggregates the quantitative features of an assay,
##' applying a summarization function (`fun`) to sets of features.
##' The `fcol` variable name points to a rowData column that defines
##' how to group the features during aggregate. This variable can
##' either be a vector (we then refer to an *aggregation by vector*)
##' or an adjacency matrix (*aggregation by matrix*).
##' 
##' The quantitative metadata are aggregated with a function (`fun.qmeta`).
##'
##' @param object An instance of class [QFeatures] or [SummarizedExperiment].
##'
##' @param i The index or name of the assay which features will be
##'     aggregated the create the new assay.
##'
##' @param fcol A `character(1)` naming a rowdata variable (of assay
##'     `i` in case of a `QFeatures`) defining how to aggregate the
##'     features of the assay. This variable is either a `character`
##'     or a (possibly sparse) matrix. See below for details.
##'
##' @param name A `character(1)` naming the new assay. Default is
##'     `newAssay`. Note that the function will fail if there's
##'     already an assay with `name`.
##'
##' @param fun A function used for quantitative feature
##'     aggregation. See Details for examples.
##'
##' @param fun.qmeta A function used for quantitative metadata
##'     aggregation. See Details for examples.
##'
##' @param ... Additional parameters passed the `fun` and `fun.qmeta`.
##'
##' @return A `QFeatures` object with an additional assay or a
##'  `SummarizedExperiment` object (or subclass thereof).
##'
##' @details
##'
##' @section Iterative aggregation function:
##' 
##' xxxxxx
##' xxxxx
##' 
##' @section Quantitative metadata aggregation:
##' 
##' xxxxxx
##' xxxx
##' 
##' The function to aggregate the quantitative metadata is
##' 
##' - `aggQmetadat()` xxxxx
##'
##' @seealso The *QFeatures* vignette provides an extended example and
##'     the *Aggregation* vignette, for a complete quantitative
##'     proteomics data processing pipeline. 
##'
##' @name aggregateFeatures4Prostar
##'
##' @rdname DaparToolshed-aggregate
##'
##' @examples
##'
##' ## ---------------------------------------
##' ## An example QFeatures with PSM-level data
##' ## ---------------------------------------
##' data(ft)
##' ft
##'
##' ## Aggregate peptides into proteins
##' ## using the adjacency matrix
##' ft <- ft <- aggregateFeatures4Prostar(object = ft,
##'                                       i = 1,
##'                                       name = 'aggregated', 
##'                                       fcol = 'adjacencyMatrix', 
##'                                       fun = colSumsMat,
##'                                       fun.qmeta = aggQmeta)
##' feat1
##'
##' assay(feat1[[1]])
##' assay(feat1[[2]])
##' aggcounts(feat1[[2]])
##' assay(feat1[[3]])
##' aggcounts(feat1[[3]])
##' rowData(ft[[2]])
NULL

##' @exportMethod aggregateFeatures4Prostar
##' @rdname DaparToolshed-aggregate
setMethod("aggregateFeatures4Prostar", "QFeatures",
          function(object, i, fcol, name = "newAssay",
                   fun = MsCoreUtils::robustSummary, ...) {
            if (isEmpty(object))
              return(object)
            if (name %in% names(object))
              stop("There's already an assay named '", name, "'.")
            if (missing(i))
              i <- main_assay(object)
            
            
            
            # Add stats on agregation
            aggAssay <- aggregateFeatures4Prostar(object[[i]], 
                                                  design(object)$Condition,
                                                  fcol, 
                                                  fun, 
                                                  ...)
            
            ## Add the assay to the QFeatures object
            object <- addAssay(object,
                               aggAssay,
                               name = name)
            ## Link the input assay to the aggregated assay
            addAssayLink(object,
                         from = i,
                         to  = name,
                         varFrom = fcol,
                         varTo = fcol)
          })


##' @exportMethod aggregateFeatures4Prostar
##' @rdname DaparToolshed-aggregate
setMethod("aggregateFeatures4Prostar", "SummarizedExperiment",
          function(object, conds, fcol, fun = MsCoreUtils::robustSummary, ...)
            .aggregateFeatures4Prostar(object, conds, fcol, fun, ...))


.aggregateFeatures4Prostar <- function(object, conds, fcol, fun, ...) {
  
  
  #browser()
  X <- adjacencyMatrix(object)
  
  # add agregation of qMetadata
  # Aggregate the quantitative metdata
  aggQ <- aggQmetadata(qMeta = qMetadata(object), 
                       X = adjacencyMatrix(object), 
                       level = typeDataset(object),
                       conds = conds)
  
  ## Remove the qMetadata that should be dropped anyway and not be aggregated
  ## within QFeatures::aggregateFeatures
  rowData(object)[['qMetadata']] <- NULL
  
  ## Create the aggregated assay
  aggAssay <- aggregateFeatures(object, fcol, fun, ...)
  
  ## Add the qMetadata to the new assay
  qMetadata(aggAssay) <- aggQ
  X.spec <- X.shared <- X
  X.spec[which(rowSums(X.spec) > 1),] <- 0
  X.shared[which(rowSums(X.shared) == 1),] <- 0
  rowData(aggAssay)[['allPeptidesUsed']] <- t(X) %*% !is.na(assay(object))
  rowData(aggAssay)[['specPeptidesUsed']] <- t(X.spec) %*% !is.na(assay(object))
  rowData(aggAssay)[['sharedPeptidesUsed']] <- t(X.shared) %*% !is.na(assay(object))
  
  
  ## Enrich the new assay
  typeDataset(aggAssay) <- 'proteins'
  idcol(aggAssay) <- NULL
 

  return(aggAssay)
}




#' @title Get the type of dataset
#' @description xxx
#'
#' @param object  An object of class 'SummarizedExperiment'
#' @param X xxxx
#' @param level A `character(1)` which is the type of dataset
#' @param conds A `character()` vector which is the names of conditions
#' for each sample in the dataset.
#'
#' @return xxxxx
#'
#' @examples
#' data(ft)
#' qMeta <- qMetadata(ft, 1)
#' X <- adjacencyMatrix(ft, 1)
#' level <- typeDataset(ft, 1)
#' conds <- colData(ft)$Condition
#' aggQmeta <- aggQmetadata(qMeta, X, level, conds)
#'
#' @rdname DaparToolshed-aggregate
#'
aggQmetadata <- function(qMeta, X, level, conds) {
  #stopifnot(inherits(object, "SummarizedExperiment"))

  rowcol <- function(meta.col, X.col)
    meta.col[X.col > 0]

  df <- data.frame(stringsAsFactors = TRUE)
  for (j in 1:ncol(qMeta))
    for(i in 1:ncol(X))
      df[i, j] <- qMetadata_combine( rowcol(qMeta[,j], X[,i]),
                                     level)

  df[df=='NA'] <- NA
  dimnames(df) <- list(colnames(X), colnames(qMeta))
  # Delete protein with only NA

  # Post processing of metacell to discover 'imputed POV', 'imputed MEC'
  df <- Set_POV_MEC_tags(conds, df, level)

  df
}
