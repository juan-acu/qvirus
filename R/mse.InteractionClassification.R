#' Mean Squared Errors for Interaction Classification
#'
#' Mean squared errors (MSE) for viral load differences
#' and CD4 count differences by comparing the actual values with the group means 
#' from the classification.
#'
#' @param object An object of class \code{InteractionClassification} containing 
#'               the classified data and clustering results.
#' @param ... Additional arguments passed to other methods (currently not used).
#' 
#' @return A `data.frame` containing the MSE for CD4 count differences (\code{mse_cds_diff})
#'         and (\code{mse_vlogs_diff}) for viral load differences.
#' @export
#'
#' @examples
#' set.seed(42)
#' data(cd_3)
#' cd_data <- cd_3[,-1]
#' cd_result <- cds_diff(cd_data)
#' data(vl_3)
#' vl_data <- vl_3[,-1]
#' vl_result <- vlogs_diff(vl_data)
#' result <- InteractionClassification(cd_result = cd_result, vl_result = vl_result)
#' mse(result)
#' 
#' @export
mse <- function(object, ...) {
  UseMethod("mse")
}

#' Mean Squared Errors for Interaction Classification
#'
#' Mean squared errors (MSE) for viral load differences
#' and CD4 count differences by comparing the actual values with the group means 
#' from the classification.
#'
#' @param object An object of class \code{InteractionClassification} containing 
#'               the classified data and clustering results.
#' @param ... Additional arguments passed to other methods (currently not used).
#' @exportS3Method mse InteractionClassification
mse.InteractionClassification <- function(object, ...){
  group_means <- summary.InteractionClassification(object)
  
  merged_result <-  
    magrittr::`%>%`(magrittr::`%>%`(magrittr::`%>%`(object, dplyr::left_join(group_means, by = "classification")),
                                    dplyr::mutate(
                                      cds_diff_e = cds3_diff - cds_diff_mean,
                                      vlogs_diff_e = vlogs3_diff - vlogs_diff_mean, 
                                      cds_diff_se = (cds_diff_e)^2,
                                      vlogs_diff_se = (vlogs_diff_e)^2
                                    )
    ),
    dplyr::summarise(
      mse_cds_diff = mean(cds_diff_se), 
      mse_vlogs_diff = mean(vlogs_diff_se), 
      n = dplyr::n(),
      .groups = 'drop'
    ))
  class(merged_result) <- c("mse.InteractionClassification", "data.frame")
  
  return(merged_result)  
}

utils::globalVariables(c("cds3_diff", "cds_diff_mean", "cds_diff_e", "cds_diff_se", "vlogs3_diff", "vlogs_diff_mean", "vlogs_diff_e", "vlogs_diff_se"))