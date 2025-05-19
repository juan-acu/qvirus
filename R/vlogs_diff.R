#' Create Mean Standardized Differences from Logarithmic Viral Load Data
#'
#' This function calculates the mean standardized differences of logarithmic viral loads across time for each individual in the dataset.
#'
#' @param vl_data A data frame of longitudinal viral load values per individual, where rows represent patients and columns represent sequential measurements across time (e.g., years or visits).
#'
#' @return An object of class `"Interaction"` with the following components:
#' \describe{
#'   \item{vlogs3_diff}{Mean standardized differences of logarithmic viral load values.}
#' }
#'
#' @export
#'
#' @examples
#' data(vl_3)
#' vl_data <- vl_3[,-1]
#' result <- vlogs_diff(vl_data)
vlogs_diff <- function(vl_data){
  # Validación básica
  if (!is.data.frame(vl_data)# || !is.data.frame(vl_data)
  ) {
    stop("Input must be data frames.")
  }
  
  #  Log transformación
  vl_log <- dplyr::transmute(vl_data, dplyr::across(dplyr::everything(), ~ ifelse(. == 0, 0, log10(.))))
 
  # Estándar log
  vlog_std <- dplyr::mutate(vl_log, dplyr::across(dplyr::everything(), ~ as.vector(scale(.))))
  vlogs3_diff <-   
       
    magrittr::`%>%`(magrittr::`%>%`(magrittr::`%>%`(dplyr::rowwise(vlog_std), dplyr::mutate(vlogs_std_diff_values = mean(diff(stats::na.omit(dplyr::c_across(dplyr::everything())))))),
                                    dplyr::ungroup()),
                    dplyr::pull(vlogs_std_diff_values)) 
  
  vlogs3_diff <- as.data.frame(vlogs3_diff)
  
  class(vlogs3_diff) <- c("Interaction", "data.frame")
  return(vlogs3_diff)
}

utils::globalVariables(c("vlogs_std_diff_values"))