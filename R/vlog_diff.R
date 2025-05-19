#' Create Mean Differences from Logarithmic Viral Load Data
#'
#' This function calculates the mean differences of lograithmic viral loads across time for each individual in the dataset.
#'
#' @param vl_data A data frame of longitudinal viral load values per individual, where rows represent patients and columns represent sequential measurements across time (e.g., years or visits).
#'
#' @return An object of class `"Interaction"` with the following components:
#' \describe{
#'   \item{vlog3_diff}{Mean differences of logarithmic viral load values.}
#' }
#'
#' @export
#'
#' @examples
#' data(vl_3)
#' vl_data <- vl_3[,-1]
#' result <- vlog_diff(vl_data)
vlog_diff <- function(vl_data){
  # Validación básica
  if (!is.data.frame(vl_data)# || !is.data.frame(vl_data)
  ) {
    stop("Input must be data frames.")
  }
  
  
  # #  Log transformación
  vl_log <- dplyr::transmute(vl_data, dplyr::across(dplyr::everything(), ~ ifelse(. == 0, 0, log10(.))))
  vlog3_diff <- 
  
  magrittr::`%>%`(magrittr::`%>%`(magrittr::`%>%`(dplyr::rowwise(vl_log), dplyr::mutate(vlog_diff_values = mean(diff(stats::na.omit(dplyr::c_across(dplyr::everything())))))),
                                  dplyr::ungroup()), dplyr::pull(vlog_diff_values))
  
  vlog3_diff <- as.data.frame(vlog3_diff)  
  
  class(vlog3_diff) <- c("Interaction", "data.frame")
  return(vlog3_diff)
}

utils::globalVariables(c("vlog_diff_values"))