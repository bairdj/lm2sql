#' Creates coefficient variable name by converting to camel case,
#' adding a prefix and removing symbols
#'
#' @param name Raw coefficient name
#' @param prefix Prefix before the name of the coefficient. Should be in camel case
#'
#' @return Converted coefficient name
#'
get_coefficient_name <- function(name, prefix = "coef") {
  replaced <- gsub("\\W", "", name)
  return(paste0(prefix, toupper(substr(replaced, 1, 1)), substr(replaced, 2, nchar(replaced))))
}
