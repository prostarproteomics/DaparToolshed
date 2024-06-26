#' @title Extends a base-palette of the package RColorBrewer to n colors.
#'
#' @description The colors in the returned palette are always in the same order
#'
#' @param n The number of desired colors in the palette
#'
#' @param base The name of the palette of the package RColorBrewer from which
#' the extended palette is built. Default value is 'Set1'.
#'
#' @return A vector composed of n color code.
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' ExtendPalette(12)
#' nPalette <- 10
#' par(mfrow = c(nPalette, 1))
#' par(mar = c(0.5, 4.5, 0.5, 0.5))
#' for (i in seq_len(nPalette)) {
#'     pal <- ExtendPalette(n = i, base = "Dark2")
#'     barplot(seq_len(length(pal)), col = pal)
#'     print(pal)
#' }
#'
#' @export
#'
ExtendPalette <- function(n = NULL, base = "Set1") {
  
  pkgs.require(c('grDevices', 'RColorBrewer', "utils"))
  
  pal <- NULL
  nMaxColors <- RColorBrewer::brewer.pal.info[base, "maxcolors"]
  if (is.null(n)) {
    n <- nMaxColors
  }
  
  limit <- nMaxColors * (nMaxColors - 1) / 2
  if (n > limit) {
    stop("Number of colors exceed limit of ", limit, " colors per palette.")
  }
  
  if (n > nMaxColors) {
    pal <- RColorBrewer::brewer.pal(nMaxColors, base)
    allComb <- utils::combn(pal, 2)
    
    for (i in seq_len(n - nMaxColors)) {
      pal <- c(pal, grDevices::colorRampPalette(allComb[, i])(3)[2])
    }
  } else {
    pal <- RColorBrewer::brewer.pal(nMaxColors, base)[seq_len(n)]
  }
  pal
}






#' @title Builds a complete color palette for the conditions given in argument
#'
#' @description xxxx
#'
#' @param conds The extended vector of samples conditions
#'
#' @param pal A vector of HEX color code that form the basis palette from which
#' to build the complete color vector for the conditions.
#'
#' @return A vector composed of HEX color code for the conditions
#'
#' @author Samuel Wieczorek
#'
#' @examples
#' data(Exp1_R25_pept, package="DaparToolshedData")
#' GetColorsForConditions(get_group(Exp1_R25_pept))
#' GetColorsForConditions(get_group(Exp1_R25_pept), ExtendPalette(2))
#'
#' @export
#'
#'
GetColorsForConditions <- function(conds, pal = NULL) {
  
  pkgs.require('RColorBrewer')
  
  
  if (missing(conds)) {
    stop("'conds' is required")
  }
  
  if (!is.null(pal) && length(unique(conds)) != length(pal)) {
    stop("The length of `conds` must be equal to the length 
            of `base_palette`.")
  }
  
  if (is.null(pal)) {
    pal <- ExtendPalette(length(unique(conds)))
  }
  
  myColors <- NULL
  for (i in seq_len(length(conds))) {
    myColors[i] <- pal[which(conds[i] == unique(conds))]
  }
  return(myColors)
}
