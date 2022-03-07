##' @title Filter features of one SE based on their rowData
##'
##' @description
##'
##' The `filterFeaturesOneSE` methods enables users to filter features
##' based on a variable in their `rowData`. It is directly inspired of the
##' function `filterFeature` of the package `QFeatures`. 
##' The first difference is that the filter only applies to one `SummarizedExperiment`
##' contained in the object rather than applying on all the SE.
##' This method generates a new `SummarizedExperiment` object which is added to the `QFeatures` object.
##' If the SE on which the filter applies is the last one of the object, then a new xxxx.
##' If it is not the last one, the new SE is added and all the further SE are deleted.
##' The features matching the
##' The filters can be provided as instances of class `AnnotationFilter` (see the package `QFeatures`)
##' or of class `FunctionFilter` (see below).
##' 
##' @section Function filters:
##'
##' The function filters are filters as defined in the
##' [DaparToolshed] package. Each filter is defined by a name (which is the name of a function)
##' and a list which contains the parameters passed to the function.
##' Those filters can be created with the `FunctionFilter` constructor.
##' 
##' Those functions are divided into two main categories:
##'  - the one that filter on one rowData feature,
##'  - the one based on a two-dimensional information such as the adjacency matrix
##'  
##'  for the first category, all filters of class [AnnotationFilter] can be used as they
##'  are used in `QFeatures`
##'  
##'  For the second category, the package `DaparToolshed` provides filter functions based either 
##'  on the adjacency matrix:
##'  - [DaparToolshed::topnPeptides()]: xxxx
##'  - [DaparToolshed::sharedPeptides()]: xxx
##'  - [DaparToolshed::specPeptides()]: xxx
##'  
##' Or based on the quantitative metadata (identification):
##'  - [DaparToolshed::qMetadatWholeMatrix()]: xxx
##'  - [DaparToolshed::qMetadataWholeLine()]: xxx
##'  - [DaparToolshed::qMetadataOnConditions()]: xxx
##' 
##' @return A filtered `QFeature` object
##' 
##' @author Samuel Wieczorek
##' 
##' @name QFeatures-filtering-oneSE
##' 
##' @rdname QFeatures-filtering-oneSE
##' 
##' @aliases filterFeaturesOneSE filterFeaturesOneSE, DaparToolsehd, FunctionFilter, VariableFilter
##' 
##' @examples 
##' 
##' ## ----------------------------------------
##' ## Creating function filters
##' ## ----------------------------------------
##' 
##' FunctionFilter('FUN', 
##'                param1 = 'value_of_param1', 
##'                param2 = 'value_of_param2')
##'                
##' FunctionFilter('qMetadataWholeLine', 
##'                cmd = 'delete', 
##'                pattern = 'imputed POV')
##'                
##' ## ----------------------------------------------------------------
##' ## Filter the last assay to keep only specific peptides. This filter 
##' ## only applies on peptide dataset.
##' ## ----------------------------------------------------------------
##'
##' spec.filter <- FunctionFilter('specPeptides', list())
##' ## using a user-defined character filter
##' filterFeaturesOneSE(feat1, list(FunctionFilter('specPeptides', list())))
##' 
##' 
##' ## ----------------------------------------------------------------
##' ## Filter the last assay to keep only specific peptides and topn peptides. The
##' ## two filters are run sequentially.
##' ## ----------------------------------------------------------------
##' 
##' lst.filters <- list(FunctionFilter('specPeptides', list()))
##' lst.filters <- append(lst.filters, 
##'                       FunctionFilter('topnPeptides', 
##'                       fun = 'rowSums', 
##'                       top = 2))
##' filterFeaturesOneSE(feat1, lst.filters)
##' 
##' ## ----------------------------------------------------------------
##' ## Filter the last assay to delete peptides where, in at least one condition,
##' ## there is less than 80% of samples marked as 'imputed POV'
##' ## ----------------------------------------------------------------
##' 
##' filter <- FunctionFilter('qMetadataOnConditions', 
##'                         cmd = 'delete',
##'                         mode = 'AtLeastOneCond',
##'                         pattern = 'imputed POV',
##'                         conds = colData(ft)$Condition,
##'                         percent = TRUE, 
##'                         th = 0.8, 
##'                         operator = '<')
##'                         
##'  filterFeaturesOneSE(feat1, filter)  
##'  
##'                        
NULL


##' @exportClass FunctionFilter
##' @rdname QFeatures-filtering-oneSE
setClass("FunctionFilter",
         slots = c(name="character", 
                   params="list"),
         prototype = list(name=character(1), 
                          params=list())
)


##' @param name `character(1)` refering to the name of the function
##'     to apply the filter on.
##'
##' @param params `character()` or `integer()` parameters for the
##'     `name` function.
##'
##' @export FunctionFilter
##' @rdname QFeatures-filtering-oneSE
FunctionFilter <- function(name, ...) {
  new("FunctionFilter",
      name = name,
      params = list(...))
}


##' @param object An instance of class [QFeatures] or [SummarizedExperiment].
##' 
##' @param i The index or name of the assay which features will be
##'     filtered the create the new assay.
##' 
##' @param name A `character(1)` naming the new assay. Default is
##'     `newAssay`. Note that the function will fail if there's
##'     already an assay with `name`.
##'
##' @param filters A `list()` containing instances of class [AnnotationFilter] or 
##'     [FunctionFilter]
##'     
##' @exportMethod filterFeaturesOneSE
##' @rdname QFeatures-filtering-oneSE
setMethod("filterFeaturesOneSE", "QFeatures",
          function(object, i, name = "newAssay", filters) {
            if (isEmpty(object))
              return(object)
            if (name %in% names(object))
              stop("There's already an assay named '", name, "'.")
            if (missing(i))
              i <- main_assay(object)
            
            if (missing(filters))
              return(object)
            
            ## Create the aggregated assay
            new.se <- filterFeaturesOneSE(object[[i]], filters)
            
            ## Add the assay to the QFeatures object
            object <- addAssay(object,
                               new.se,
                               name = name)
            
            if (nrow(new.se) > 0){
              idcol <- metadata(object[[i]])$idcol
              if (is.null(idcol)){
                warning('xxx')
                metadata(object[[i]])$idcol <- '_temp_ID_'
                idcol <- '_temp_ID_'
              }
                
              
              ## Link the input assay to the aggregated assay
              rowData(object[[i]])[,idcol] <- rownames(object[[i]])
              rowData(object[[name]])[,idcol] <- rownames(object[[name]])
              object <- addAssayLink(object,
                                     from = names(object)[i],
                                     to  = name,
                                     varFrom = idcol,
                                     varTo = idcol)
            }
            
            return(object) 
          })



##' @importFrom BiocGenerics do.call
##' @exportMethod filterFeaturesOneSE
##' @rdname QFeatures-filtering-oneSE
setMethod("filterFeaturesOneSE", "SummarizedExperiment",
          function(object, filters){
            for (f in filters){
              if (inherits(f, "AnnotationFilter")){
                x <- rowData(object)
                sel <- if (field(f) %in% names(x)){
                  do.call(condition(f),
                          list(x[, field(f)],
                               value(f)))
                } else{
                  rep(FALSE, nrow(x))
                }

                object <- object[sel]
              }
              else if (inherits(f, "FunctionFilter"))
                object <- do.call(f@name, 
                                  append(list(object=object), f@params))
            }
            return(object)
          }
)