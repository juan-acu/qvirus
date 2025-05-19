#' Create Mean Standardized Differences from Longitudinal CD4 Data
#'
#' This function calculates the mean standardized differences of CD4 counts across time for each individual in the dataset.
#'
#' @param cd_data A data frame of longitudinal CD4 count values per individual, where rows represent patients and columns represent sequential measurements across time (e.g., years or visits).
#'
#' @return An object of class `"Interaction"` with the following components:
#' \describe{
#'   \item{cds3_diff}{Mean standardized differences of raw CD4 count values.}
#' }
#'
#' @export
#'
#' @examples
#' data(cd_3)
#' cd_data <- cd_3[,-1]
#' result <- cds_diff(cd_data)
cds_diff <- function(cd_data){
  # Validación básica
  if (!is.data.frame(cd_data)# || !is.data.frame(vl_data)
  ) {
    stop("Input must be data frames.")
  }
  cd_std <- dplyr::mutate(cd_data, dplyr::across(dplyr::everything(), ~ as.vector(scale(.))))
  cds3_diff <-  
    
    magrittr::`%>%`(magrittr::`%>%`(magrittr::`%>%`(dplyr::rowwise(cd_std), dplyr::mutate(cd_std_diff_values = mean(diff(stats::na.omit(dplyr::c_across(dplyr::everything())))))),
                                    dplyr::ungroup()),
                    dplyr::pull(cd_std_diff_values))
  
  cds3_diff <- as.data.frame(cds3_diff)
  class(cds3_diff) <- c("Interaction", "data.frame")
  return(cds3_diff)
}

utils::globalVariables(c("cd_std_diff_values"))