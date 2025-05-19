#' Summarize Payoffs
#'
#' This function summarizes the payoffs object by classification.
#'
#' @param object A payoffs object.
#' @param ... Additional arguments (not used). 
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
#' summary(payoffs_results)
summary <- function(object, ...) {
  UseMethod("summary")
}

#' Summarize Payoffs
#'
#' This function summarizes the payoffs object by classification.
#'
#' @param object A payoffs object.
#' @param ... Additional arguments (not used). 
#' @exportS3Method summary payoffs
summary.payoffs <- function(object, ...){
  group_means <- 
    magrittr::`%>%`(magrittr::`%>%`(object, dplyr::group_by(classification)),
                    dplyr::summarise(
                      cds_diff_mean = mean(cds3_diff), 
                      vlogs_diff_mean = mean(vlogs3_diff), 
                      payoff_mean = mean(predictions),
                      n = dplyr::n(),
                      .groups = 'drop'
                    )) 
  class(group_means) <- c("summary.payoffs", "data.frame")
  
  return(group_means)
}

utils::globalVariables(c("classification", "cds3_diff", "vlogs3_diff", "cds_diff_mean", "vlogs_diff_mean", "predictions", "payoff_mean"))