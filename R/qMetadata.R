
#' @title Quantitative metadata vocabulary for entities
#' 
#' @description
#' This function gives the vocabulary used for the quantitative metadata of each entity in
#' each condition.
#' 
#' @section Glossary:
#' 
#' Peptide-level vocabulary
#' 
#' |-- 1.0 Quantitative Value
#' |    |
#' |    |-- 1.1 Identified (color 4, white)
#' |    |
#' |    |-- 1.2 Recovered (color 3, lightgrey)
#' |
#' |-- 2.0 Missing value (no color)
#' |    |
#' |    |-- 2.1 Missing POV (color 1)
#' |    |
#' |    |-- 2.2 Missing MEC (color 2)
#' |
#' |-- 3.0 Imputed value
#' |    |
#' |    |-- 3.1 Imputed POV (color 1)
#' |    |
#' |    |-- 3.2 Imputed MEC (color 2)
#'        
#'  
#'  
#' Protein-level vocabulary:
#' 
#' |-- 1.0 Quantitative Value
#' |    |
#' |    |-- 1.1 Identified (color 4, white)
#' |    |
#' |    |-- 1.2 Recovered (color 3, lightgrey)
#' |
#' |-- 2.0 Missing value
#' |    |
#' |    |-- 2.1 Missing POV (color 1)
#' |    |
#' |    |-- 2.2 Missing MEC (color 2)
#' |
#' |-- 3.0 Imputed value
#' |    |
#' |    |-- 3.1 Imputed POV (color 1)
#' |    |
#' |    |-- 3.2 Imputed MEC (color 2)
#' |
#' |-- 4.0 Combined value (color 3bis, light-lightgrey)
#' 
#' 
#' @section Conversion to the glossary:
#' 
#' A generic conversion
#' 
#' Conversion for Proline datasets
#' 
#' Conversion from Maxquant datasets
#' 
#' 
#' @name q_metadata
#' 
#' @examples 
#' 
#' 
#' 
#' #-----------------------------------------------
#' # A shiny app to view color legends 
#' #-----------------------------------------------
#' if(interactive()){
#' data(ft)
#' ui <- mod_qMetadataLegend_ui("legend")
#' 
#' server <- function(input, output, session) {
#'   mod_qMetadataLegend_server('legend',
#'                                 object = reactive({ft[[1]]}))
#'   }
#'   
#'  shinyApp(ui = ui, server = server)
#'   
#'   
#' }
NULL



#' @param level A string designing the type of entity/pipeline. 
#' Available values are: `peptide`, `protein`
#' 
#' @return A data.frame containing the different tags and corresponding colors for the level
#' given in parameter
#' 
#' @author Thomas Burger, Samuel Wieczorek
#'
#' @export
#'
#' @rdname q_metadata
#' 
qMetadata.def <- function(level = 'all'){
  if(is.null(level))
    return()
  if(missing(level))
    stop("'level' is required.")
  def <- switch(level,
                peptide = {
                  node <- c('all', 
                            'quanti', 
                            'identified', 
                            'recovered', 
                            'missing',
                            'missing POV', 
                            'missing MEC', 
                            'imputed',
                            'imputed POV', 
                            'imputed MEC')
                  parent <- c('', 
                              'all', 
                              'quanti', 
                              'quanti', 
                              'all', 
                              'missing', 
                              'missing',
                              'all',
                              'imputed',
                              'imputed')
                  data.frame(node = node,
                             parent = parent)
                },
                
                
                protein = {
                  node <- c('all',
                            'quanti',
                            'identified',
                            'recovered',
                            'missing',
                            'missing POV',
                            'missing MEC',
                            'imputed',
                            'imputed POV',
                            'imputed MEC',
                            'combined')
                  parent <- c('',
                              'all',
                              'quanti',
                              'quanti',
                              'all',
                              'missing',
                              'missing',
                              'all',
                              'imputed',
                              'imputed',
                              'all')
                  
                  data.frame(node = node,
                             parent = parent)
                }
  )
  
  
  
  
  #def <- cbind(def, color = rep('white', nrow(def)))
  
  #for(n in seq_len(nrow(def)))
  #  def[n, 'color'] <- colors[[def[n, 'node']]]
  

  if (level == 'all')
    def = union(qMetadata.def('peptide'), 
                qMetadata.def('protein'))
  
  return(def)

}


#' @export
#' @rdname q_metadata
custom_qMetadata_colors <- function()
  list('all' = 'white',
       'missing' = 'white',
       'missing POV' = "lightblue",
       'missing MEC' = "orange",
       'quanti' = "white",
       'recovered' = "lightgrey",
       'identified' = "white",
       'combined' = "red",
       'imputed' = "white",
       'imputed POV' = "#0040FF",
       'imputed MEC' = "#DF7401")


#' @title Sets the MEC tag in the qMetadata
#' 
#' @description 
#' 
#' This function is based on the qMetadata dataframe to look for either missing
#' values (used to update an initial dataset) or imputed values (used when
#' post processing protein qMetadata after aggregation)
#' 
#' @param conds A 1-col dataframe with the condition associated to each sample.
#' @param df An object of class \code{SummarizedExperiment}
#' @param level Type of entity/pipeline
#' 
#' @return An instance of class \code{MSnSet}.
#' 
#' @author Samuel Wieczorek
#' 
#' @examples 
#' data(ft_na)
#' df <- assay(ft_na, 2)
#' level <- typeDataset(ft_na, 1)
#' df <- Set_POV_MEC_tags(ft_na, 1, level)
#'
#' @export
#'
#' @name Set_POV_MEC_tags
#' @rdname q_metadata
#' 
#' 
Set_POV_MEC_tags <- function(conds, df, level){
  u_conds <- unique(conds)
  for (i in seq_len(length(u_conds))){
    ind.samples <- which(conds == u_conds[i])
    
    ind.imputed <- match.qMetadata(df[, ind.samples], 'imputed', level)
    ind.missing <- match.qMetadata(df[, ind.samples], 'missing', level)
    ind.missing.pov <- ind.missing & rowSums(ind.missing) < length(ind.samples) & rowSums(ind.missing) > 0
    ind.missing.mec <- ind.missing &  rowSums(ind.missing) == length(ind.samples)
    ind.imputed.pov <- ind.imputed & rowSums(ind.imputed) < length(ind.samples) & rowSums(ind.imputed) > 0
    ind.imputed.mec <- ind.imputed &  rowSums(ind.imputed) == length(ind.samples)
    
    df[,ind.samples][ind.imputed.mec] <- 'imputed MEC'
    df[,ind.samples][ind.missing.mec] <- 'missing MEC'
    df[,ind.samples][ind.imputed.pov] <- 'imputed POV'
    df[,ind.samples][ind.missing.pov]  <- 'missing POV'
    }
  df
  }




#' @param from xxx
#' 
#' @param level xxx
#' 
#' @param qdata A matrix of quantitative data
#' 
#' @param conds xxx
#' 
#' @param df A list of integer xxxxxxx
#' 
#' @return xxxxx
#' 
#' @author Samuel Wieczorek
#' 
#' @examples 
#' file <- system.file("extdata", "Exp1_R25_pept.txt", package="DaparToolshedData")
#' data <- read.table(file, header=TRUE, sep="\t",stringsAsFactors = FALSE)
#' metadataFile <- system.file("extdata", "samples_Exp1_R25.txt", 
#' package="DaparToolshedData")
#' metadata <- read.table(metadataFile, header=TRUE, sep="\t", as.is=TRUE, 
#' stringsAsFactors = FALSE)
#' conds <- metadata$Condition
#' qdata <- data[,56:61]
#' df <- data[ , 43:48]
#' df <- BuildqMetadata('maxquant', 'peptide', qdata, conds, df)
#' df <- BuildqMetadata('proline', 'peptide', qdata, conds, df)
#' 
#' @export
#' 
#' @rdname q_metadata
#' 
#'  
BuildqMetadata <- function(from = NULL, 
                           level,
                           qdata = NULL,
                           conds = NULL, 
                           df = NULL){
  if (missing(from))
    stop("'from' is required.")
  if (missing(level))
    stop("'level' is required.")
  if (is.null(qdata))
    stop("'qdata' is required.")
  if (is.null(conds))
    stop("'conds' is required.")
  
  
  if (is.null(df) || is.null(from))
    df <- qMetadata_generic(qdata, conds, level)
  else
    switch(from,
           maxquant = df <- qMetadata_maxquant(qdata, conds, df, level),
           proline = df <- qMetadata_proline(qdata, conds, df, level)
    )
  
  return(df)
}





#' @title Sets the qMetadata dataframe
#' 
#' @description
#' 
#' In the quantitative columns, a missing value is identified by no value rather
#' than a value equal to 0. 
#' Conversion rules
#' Quanti			Tag		
#' NA or 0		NA		
#'
#' 
#' @param qdata A matrix of quantitative data
#' 
#' @param conds xxx
#' 
#' @param level xxx
#' 
#' @return xxxxx
#' 
#' @author Samuel Wieczorek
#' 
#' @examples 
#' file <- system.file("extdata", "Exp1_R25_pept.txt", package="DaparToolshedData")
#' data <- read.table(file, header=TRUE, sep="\t",stringsAsFactors = FALSE)
#' metadataFile <- system.file("extdata", "samples_Exp1_R25.txt", 
#' package="DaparToolshedData")
#' metadata <- read.table(metadataFile, header=TRUE, sep="\t", as.is=TRUE, 
#' stringsAsFactors = FALSE)
#' conds <- metadata$Condition
#' qdata <- data[seq_len(100), seq(56, 61)]
#' df <- data[seq_len(100) , seq(43,48)]
#' df <- qMetadata_generic(qdata, conds, 'peptide')
#' 
#' @export
#' 
#' @rdname q_metadata
#' 
#'  
qMetadata_generic <- function(qdata, conds, level){
  
  if (missing(qdata))
    stop("'qdata' is required")
  if (missing(conds))
    stop("'conds' is required.")
  if (missing(level))
    stop("'level' is required.")
  
  df <- data.frame(matrix(rep('quanti', nrow(qdata)*ncol(qdata)),
                          nrow = nrow(qdata),
                          ncol = ncol(qdata)),
                   stringsAsFactors = FALSE) 
  
  # Rule 1
  qdata[qdata == 0] <- NA
  df[is.na(qdata)] <-  'missing'
  
  df <- Set_POV_MEC_tags(conds, df, level)
  
  colnames(df) <- paste0("qMetadata_", colnames(qdata))
  colnames(df) <- gsub(".", "_", colnames(df), fixed=TRUE)
  
  return(df)
}





#' @title Sets the qMetadata dataframe
#' 
#' @description
#' 
#' In the quantitative columns, a missing value is identified by no value rather
#' than a value equal to 0. 
#' Conversion rules
#' Initial conversion rules for maxquant
#' 
#' |--------------|-----------------|-----|
#' | Quanti       |    PSM count    | Tag |
#' |--------------|-----------------|-----|
#' |  == 0 | N.A.	|   whatever 			| 2.0 |
#' |  > 0		  		|    > 0		     	| 1.1 |
#' |  > 0		  		|    == 0	      	| 1.2 |
#' |  > 0		  		|   unknown col   | 1.0 |
#' |--------------|-----------------|-----|
#' 
#' @param qdata A matrix of quantitative data
#' 
#' @param conds xxx
#' 
#' @param df A list of integer xxxxxxx
#' 
#' @param level xxx
#' 
#' @return xxxxx
#' 
#' @author Samuel Wieczorek
#' 
#' @examples
#' \donttest{ 
#' file <- system.file("extdata", "Exp1_R25_pept.txt", package="DaparToolshedData")
#' data <- read.table(file, header=TRUE, sep="\t",stringsAsFactors = FALSE)
#' metadataFile <- system.file("extdata", "samples_Exp1_R25.txt", 
#' package="DaparToolshedData")
#' metadata <- read.table(metadataFile, header=TRUE, sep="\t", as.is=TRUE, 
#' stringsAsFactors = FALSE)
#' conds <- metadata$Condition
#' qdata <- data[seq_len(100), seq(56, 61)]
#' df <- data[seq_len(100) , seq(43, 48)]
#' df <- qMetadata_proline(qdata, conds, df, 'peptide')
#' }
#' 
#' @export

#' @rdname q_metadata
#' 
#'  
qMetadata_proline <- function(qdata, 
                              conds, 
                              df, 
                              level = NULL){
  if (missing(qdata))
    stop("'qdata' is required")
  if (missing(conds))
    stop("'conds' is required.")
  if (missing(level))
    stop("'level' is required.")
  
  
  if (is.null(df))
    df <- data.frame(matrix(rep('quanti', nrow(qdata)*ncol(qdata)), 
                            nrow = nrow(qdata),
                            ncol = ncol(qdata)),
                     stringsAsFactors = FALSE) 
  
  # Rule 1
  df[is.na(qdata)] <-  'missing'
  df <- Set_POV_MEC_tags(conds, df, level)
  
  # Rule 2
  df[df > 0 & qdata > 0] <- 'identified'
  
  # Rule 3
  df[df == 0 & qdata > 0] <- 'recovered'
  
  colnames(df) <- paste0("qMetadata_", colnames(qdata))
  colnames(df) <- gsub(".", "_", colnames(df), fixed=TRUE)
  
  return(df)
}

#' @title Sets the quantitative metadata dataframe for maxquant datasets
#' 
#' @description 
#' 
#' Initial conversion rules for maxquant
#' |------------|-----------------------|--------|
#' | Quanti     |     Identification    |    Tag |
#' |------------|-----------------------|--------|
#' |  == 0			|       whatever 				|    2.0 |
#' |  > 0				|       'By MS/MS'			|    1.1 |
#' |  > 0				|      'By matching'		|    1.2 |
#' |  > 0				|       unknown col			|    1.0 |
#' |------------|-----------------------|--------|
#' 
#' @param qdata A matrix of quantitative data
#' 
#' @param conds xxx
#' 
#' @param df A list of integer xxxxxxx
#' 
#' @param level xxx
#' 
#' @return xxxxx
#' 
#' @author Samuel Wieczorek
#' 
#' @examples 
#' file <- system.file("extdata", "Exp1_R25_pept.txt", package="DaparToolshedData")
#' data <- read.table(file, header=TRUE, sep="\t",stringsAsFactors = FALSE)
#' metadataFile <- system.file("extdata", "samples_Exp1_R25.txt", 
#' package="DaparToolshedData")
#' metadata <- read.table(metadataFile, header=TRUE, sep="\t", as.is=TRUE, 
#' stringsAsFactors = FALSE)
#' conds <- metadata$Condition
#' qdata <- data[seq_len(10),seq(56, 61)]
#' df <- data[seq_len(10) , seq(43, 48)]
#' df2 <- qMetadata_maxquant(qdata, conds, df, 'peptide')
#' 
#' @export
#' @rdname q_metadata
#' 
#' 
qMetadata_maxquant <- function(qdata, 
                               conds, 
                               df, 
                               level = NULL){
  
  if (missing(qdata))
    stop("'qdata' is required")
  if (missing(conds))
    stop("'conds' is required.")
  if (missing(level))
    stop("'level' is required.")
  
  
  if (is.null(df))
    df <- data.frame(matrix(rep('quanti', 
                                nrow(qdata)*ncol(qdata)), 
                            nrow=nrow(qdata),
                            ncol=ncol(qdata)),
                     stringsAsFactors = FALSE) 
  
  
  # Rule 1
  qdata[qdata == 0] <-  NA
  
  # Rule 2
  df[df=='byms/ms'] <- 'identified'
  
  # Rule 3
  df[df=='bymatching'] <- 'recovered'
  
  # Add details for NA values
  df[is.na(qdata)] <-  'missing'
  df <- Set_POV_MEC_tags(conds, df, level)
  
  colnames(df) <- paste0("qMetadata_", colnames(qdata))
  colnames(df) <- gsub(".", "_", colnames(df), fixed=TRUE)
  
  return(df)
}






#' Similar to the function \code{is.na} but focused on the equality with 
#' the paramter 'type'.
#'
#' @title Similar to the function \code{is.na} but focused on the equality 
#' with the paramter 'type'.
#'
#' @param df A data.frame
#'
#' @param pattern The value to search in the dataframe
#' 
#' @param level xxx
#'
#' @return A boolean dataframe
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' data(ft)
#' obj <- ft[[1]]
#' metadata <- qMetadata(obj)
#' m <- match.qMetadata(metadata, "missing", 'peptide')
#'
#' @export
#' 
#' @rdname q_metadata
#' 
#'
match.qMetadata <- function(df, pattern, level){
  if (missing(df))
    stop("'df' is required")
  if (missing(pattern))
    stop("'pattern' is required.")
  if (missing(level))
    stop("'level' is required.")
  
  
  if (!(pattern %in% qMetadata.def(level)$node))
    stop(paste0("'pattern' is not correct. Availablevalues are: ", 
                paste0(qMetadata.def(level)$node, collapse = ' ')))
  
  ll.res <- lapply(search.qMetadata.tags(pattern = pattern, level), 
                   function(x){as.data.frame(df)==x})
  
  res <- NULL
  for (i in seq_len(length(ll.res)))
    if (i==1){
      res <- ll.res[[1]]
    } else {
      res <- res | ll.res[[i]]
    }
  
  return(res)
}

#' @title
#' 
#' Update quantitative metadata after imputation
#' 
#' @description
#' 
#' Update the quantitative metadata information of missing values that were imputed
#' 
#' @param object xxx
#' @param from xxx
#' @param to xxx
#' @param ... xxx
#' 
#' @examples
#' 
#' obj <- Exp1_R25_pept[seq_len(10),]
#' obj[[2]] <- UpdateqMetadata(obj[[2]], 'missing', 'imputed')
#' 
#' @author Samuel Wieczorek
#'
#' 
#' @return NA
#' 
#' @rdname q_metadata
#' 
setMethod("UpdateqMetadata", "SummarizedExperiment",
          function(object,
                   from,
                   to,
                   ...) {
            
            if (missing(object))
              stop("'object' is required.")
            level <- typeDataset(object)
            if (missing(na.type)){
              values <- unname(search.qMetadata.tags('missing', level))
              stop("'na.type' is required. Available values are: ", 
                   paste0(values, collapse=' '))
            }
            
            
            ind <- match.qMetadata(metadata = qMetadata(object), 
                                  pattern = na.type, 
                                  level = level) & !is.na(SummarizedExperiment::assay(object))
            
            rowData(object)$qMetadata_names[ind] <- gsub(from, 
                                                         to, 
                                                         rowData(object)$qMetadata_names[ind],
                                                         fixed = TRUE)
            object
          })


#' @title
#' Search pattern in qMetadata vocabulary
#' 
#' @description
#' Gives all the tags of the metadata vocabulary containing the pattern 
#' (parent and all its children).
#' 
#' @param pattern The string to search.
#' 
#' @param level The available levels are : names()
#' 
#' @param depth xxx
#' 
#' @author Samuel Wieczorek
#' 
#' @examples
#' search.qMetadata.tags('missing POV', 'peptide')
#' search.qMetadata.tags('quanti', 'peptide')
#' 
#' @export
#' @return NA
#' 
#' @rdname q_metadata
#' 
#' 
search.qMetadata.tags <- function(pattern, level, depth = '1'){
  if(missing(pattern))
    stop("'pattern' is required.")
  else if (!(pattern %in% qMetadata.def(level)$node))
    stop(paste0("'pattern' must be one of the following: ", paste0(qMetadata.def(level)$node, collapse=' ')))
  
  if(missing(level))
    stop("'level' is required.")
  if(!(depth %in% c('0', '1', '*')))
    stop("'depth' must be one of the following: 0, 1 or *")
  
  tags <- NULL
  tags <- switch(depth,
                 '0' = pattern,
                 '1' = c(pattern, qMetadata.def(level)$node[which(qMetadata.def(level)$parent == pattern)]),
                 '*' = {
                   if (length(qMetadata.def(level)$node[which(qMetadata.def(level)$parent == pattern)])==0) 
                     search.qMetadata.tags(pattern, level, '0')
                   
                   else
                     c(pattern, unlist(lapply(qMetadata.def(level)$node[which(qMetadata.def(level)$parent == pattern)],
                                              function(x) {
                                                search.qMetadata.tags(x, level, depth)
                                              }
                     ))
                     )
                 }
  )
  
  return(tags)
  
}



#' @title
#' 
#' Combine peptide metadata to build protein metadata
#' 
#' @description
#' 
#' Agregation rules for the cells quantitative metadata of peptides. 
#' Please refer to the qMetadata.def vocabulary in `qMetadata.def()`
#' 
#' # Basic agreagtion
#' Agregation of non imputed values (2.X) with quantitative values 
#' (1.0, 1.X, 3.0, 3.X)
#' |----------------------------
#' Not possible
#' |----------------------------
#' 
#' Agregation of different types of missing values (among 2.1, 2.2)
#' |----------------------------
#' * Agregation of 2.1 peptides between each other gives a missing value 
#'   non imputed (2.0)
#' * Agreagtion of 2.2 peptides between each other givesa missing value 
#'   non imputed (2.0)
#' * Agregation of a mix of 2.1 and 2.2 gives a missing value non imputed (2.0)
#' |----------------------------
#' 
#' 
#' Agregation of a mix of quantitative values (among 1.0, 1.1, 1.2, 3.0, 3.X)
#' |----------------------------
#' * if the type of all the peptides to agregate is 1.0, 1.1 or 1.2, 
#'   then the final metadata is set the this tag
#' * if the set of metacell to agregate is a mix of 1.0, 1.1 or 1.2, 
#'   then the final metadata is set to 1.0
#' * if the set of metacell to agregate is a mix of 3.X and 3.0, 
#'   then the final metadata is set to 3.0
#' * if the set of metacell to agregate is a mix of 3.X and 3.0 and other (X.X),
#'   then the final metadata is set to 4.0
#' |----------------------------
#' 
#' # Post processing
#' Update metacell with POV/MEC status for the categories 2.0 and 3.0
#' TODO
#' 
#' @param met xxx
#' 
#' @param level xxx
#' 
#' @examples
#' \dontrun{
#' ll <- qMetadata.def('peptide')$node
#' for (i in 1:length(ll))
#' test <- lapply(combn(ll, i, simplify = FALSE), 
#' function(x) tag <- qMetadata_combine(x, 'peptide'))
#' }
#' 
#' @export
#' @rdname q_metadata
#' @importFrom utils combn
#' 
#' 
qMetadata_combine <- function(met, level) {
  tag <- NULL
  if (length(met)==0)
    return('missing')
  
  u_met <- unique(met)
  
  # Define an auxiliary function
  ComputeNbTags <- function(tag){
    sum(unlist(lapply( search.qMetadata.tags(tag, level), 
                       function(x) length(grep(x, u_met)))))
  }
  
  
  nb.tags <- lapply(qMetadata.def(level)$node, 
                    function(x) as.numeric(x %in% u_met))
  n.imputed <- ComputeNbTags('imputed')
  n.missing <- ComputeNbTags('missing')
  n.quanti <- ComputeNbTags('quanti')
  
  
  if(n.missing > 0 && (n.imputed > 0 || n.quanti > 0)) tag <- 'STOP'
  # stop("You try to combine missing values (2.X) with quantitative values (1.X or 3.X).")
  
  # sw : Agregation of a mix of 2.X gives a missing value non imputed (2.0)
  if (n.missing > 0 && n.quanti == 0 && n.imputed == 0) tag <- 'missing'
  
  
  # # Agregation of a mix of 2.1 and 2.2 gives a missing value non imputed (2.0)
  # if (length(u_met)== length(grep('missing_', u_met))) tag <- 'missing'
  # 
  # # Agreagtion of 2.2 peptides between each other givesa missing value non imputed (2.0)
  # if (length(u_met)==1 && 'missing_MEC' == u_met) tag <- 'missing'
  # 
  # # Agreagtion of 2.2 peptides between each other gives a missing value non imputed (2.0)
  # if (length(u_met)==1 && 'missing_POV' == u_met) tag <- 'missing'
  #     
  # # Agregation of 2.1 peptides between each other gives a missing value non imputed (2.0)
  # if (length(u_met)==1 && 'missing_MEC' == u_met) tag <- 'missing'
  
  # if the type of all the peptides to agregate is 1.0, 1.1 or 1.2, then the final
  # metadata is set the this tag
  if (length(u_met)==1 && u_met == 'quanti') tag <- 'quanti'
  if (length(u_met)==1 && u_met == 'identified') tag <- 'identified'
  if (length(u_met)==1 && u_met == 'recovered') tag <- 'recovered'
  
  
  # if the set of metacell to agregate is a mix of 1.0, 1.1 or 1.2, then the final
  # metadata is set to 1.0
  if (n.quanti > 1 && n.imputed == 0 && n.missing==0) tag <- 'quanti'
  
  
  # If the set of metacell to agregate is a mix of 3.X and 3.0, then the final
  # metadata is set to 3.0
  if (n.quanti == 0 && n.imputed > 0 && n.missing == 0) tag <- 'imputed'
  
  # If the set of metacell to agregate is a mix of 3.X and 3.0 and other (X.X), 
  # then the final metadata is set to 4.0
  if (n.quanti > 0 && n.imputed > 0 && n.missing == 0)
    tag <- 'combined'
  
  #print(paste0(paste0(u_met, collapse=' '), ' ---> ', tag))
  return(tag)
}


