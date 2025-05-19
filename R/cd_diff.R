#' Create Mean Differences from Longitudinal CD4 Data
#'
#' This function calculates the mean differences of CD4 counts across time for each individual in the dataset.
#'
#' @param cd_data A data frame of longitudinal CD4 count values per individual, where rows represent patients and columns represent sequential measurements across time (e.g., years or visits).
#'
#' @return An object of class `"Interaction"` with the following components:
#' \describe{
#'   \item{cd3_diff}{Mean differences of raw CD4 count values.}
#' }
#' 
#' @export
#'
#' @examples
#' data(cd_3)
#' cd_data <- cd_3[,-1]
#' result <- cd_diff(cd_data)
cd_diff <- function(cd_data){
  # Validación básica
  if (!is.data.frame(cd_data)# || !is.data.frame(vl_data)
  ) {
    stop("Input must be data frames.")
  }
  
  # Calcular diferencia media CD4
  cd3_diff <-  
    magrittr::`%>%`(magrittr::`%>%`(magrittr::`%>%`(dplyr::rowwise(cd_data), dplyr::mutate(cd_diff_values = mean(diff(stats::na.omit(dplyr::c_across(dplyr::everything())))))),
                                    dplyr::ungroup()), 
                    dplyr::pull(cd_diff_values)
    )
  cd3_diff <- as.data.frame(cd3_diff)
  class(cd3_diff) <- c("Interaction", "data.frame")
  return(cd3_diff)
}

utils::globalVariables(c("cd_diff_values"))