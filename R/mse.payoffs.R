#' Mean Squared Errors for Payoff Predictions
#'
#' Computes the mean squared error (MSE) between observed CD4 and viral load differences 
#' and their corresponding predicted payoff values within each interaction classification.
#'
#' @param object An object of class `payoffs`.
#' @param ... Additional arguments passed to other methods (currently not used).
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
#' mse(payoffs_results)
#' 
#' @export
mse <- function(object, ...) {
  UseMethod("mse")
}

#' Mean Squared Errors for Payoff Predictions
#'
#' Computes the mean squared error (MSE) between observed CD4 and viral load differences 
#' and their corresponding predicted payoff values within each interaction classification.
#'
#' @param object An object of class `payoffs`.
#' @param ... Additional arguments passed to other methods (currently not used).
#' @exportS3Method mse payoffs
mse.payoffs <- function(object, ...){
  
  merged_result <- 
    magrittr::`%>%`(magrittr::`%>%`(object,
                                    dplyr::mutate(
                                      payoffs_cds_e = cds3_diff - predictions,
                                      payoffs_vlogs_e = vlogs3_diff - predictions, 
                                      payoffs_cds_se = (payoffs_cds_e)^2,
                                      payoffs_vlogs_se = (payoffs_vlogs_e)^2
                                    )
    ),
    dplyr::summarise(
      mse_pi_cds = mean(payoffs_cds_se), 
      mse_pi_vlogs = mean(payoffs_vlogs_se), 
      n = dplyr::n(),
      .groups = 'drop'
    ))
  
  class(merged_result) <- c("mse.payoffs", "data.frame")
  
  return(merged_result)  
}

utils::globalVariables(c("cds3_diff", "payoffs_cds_e", "payoffs_cds_se", "vlogs3_diff", "payoffs_vlogs_e", "payoffs_vlogs_se", "mse_pi_cds", "mse_pi_vlogs"))
