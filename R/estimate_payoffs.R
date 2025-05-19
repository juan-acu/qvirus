#' Estimate Payoff Parameters for HIV Phenotype Interactions
#'
#' This function estimates the payoff parameters for HIV phenotype interactions
#' based on the provided classification object and predictions from a viral
#' load model. It calculates the mean differences in viral loads and CD4 counts,
#' as well as the average payoffs for each classification.
#'
#' @param object An object of class `InteractionClassification` containing
#' the data on viral load differences and CD4 counts.
#' @param predictions A `data.frame` containing predictions of viral loads or CD4 values.
#'
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
#' data(preds)
#' payoffs_results <- estimate_payoffs(result, preds)
estimate_payoffs <- function(object, predictions){
  group_means <- summary.InteractionClassification(object)
  
  merged_result <-  
    magrittr::`%>%`(magrittr::`%>%`(magrittr::`%>%`(object, dplyr::left_join(group_means, by = "classification")),
                                    dplyr::mutate(
                                      cds_diff_e = cds3_diff - cds_diff_mean,
                                      vlogs_diff_e = vlogs3_diff - vlogs_diff_mean, 
                                      cds_diff_se = (cds_diff_e)^2,
                                      vlogs_diff_se = (vlogs_diff_e)^2
                                    )), 
    dplyr::bind_cols(payoffs = predictions))
  class(merged_result) <- c("payoffs", "data.frame")
  
  return(merged_result)  
  
}

utils::globalVariables(c("cds3_diff", "cds_diff_mean", "cds_diff_e", "cds_diff_se", "vlogs3_diff", "vlogs_diff_mean", "vlogs_diff_e", "vlogs_diff_se"))