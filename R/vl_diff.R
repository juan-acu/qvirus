#' Create Mean Differences from Longitudinal Viral Load Data
#'
#' This function calculates the mean differences of viral loads across time for each individual in the dataset.
#'
#' @param vl_data A data frame of longitudinal viral load values per individual, where rows represent patients and columns represent sequential measurements across time (e.g., years or visits).
#'
#' @return An object of class `"Interaction"` with the following components:
#' \describe{
#'   \item{vl_diff}{Mean differences of raw viral load values.}
#' }
#'
#' @export
#'
#' @examples
#' data(vl_3)
#' vl_data <- vl_3[,-1]
#' result <- vl_diff(vl_data)
vl_diff <- function(vl_data){
  # Validación básica
  if (!is.data.frame(vl_data)# || !is.data.frame(vl_data)
  ) {
    stop("Input must be data frames.")
  }
  
  # Diferencias carga viral
  vl3_diff <- 
    magrittr::`%>%`(magrittr::`%>%`(magrittr::`%>%`(dplyr::rowwise(vl_data), dplyr::mutate(vl_diff_values = mean(diff(stats::na.omit(dplyr::c_across(dplyr::everything())))))),
                                     dplyr::ungroup()),
                     dplyr::pull(vl_diff_values))
  
  vl3_diff <- as.data.frame(vl3_diff)    
  
  class(vl3_diff) <- c("Interaction", "data.frame")
  return(vl3_diff)
}

utils::globalVariables(c("vl_diff_values"))