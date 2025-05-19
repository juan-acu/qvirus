#' Summarize an InteractionClassification object
#'
#' Computes summary statistics by classification group from an object of class
#' `InteractionClassification`, including mean differences in viral load and CD4 counts,
#' and the number of observations per cluster.
#'
#' @param object An object of class `InteractionClassification` returned by the
#'   [InteractionClassification()] function.
#' @param ... Additional arguments passed to other methods (currently not used).   
#'
#' @returns A `data.frame` with one row per interaction cluster and the following columns:
#' \describe{
#'   \item{classification}{Cluster label (as factor).}
#'   \item{cds_diff_mean}{Mean of CD4 differences in the group.}
#'   \item{vlogs_diff_mean}{Mean of viral load differences in the group.}
#'   \item{n}{Number of observations in the group.}
#' }
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
#' summary(result)
summary <- function(object, ...) {
  UseMethod("summary")
}

#' Summarize an InteractionClassification object
#'
#' Computes summary statistics by classification group from an object of class
#' `InteractionClassification`, including mean differences in viral load and CD4 counts,
#' and the number of observations per cluster.
#'
#' @param object An object of class `InteractionClassification` returned by the
#'   [InteractionClassification()] function.
#' @param ... Additional arguments passed to other methods (currently not used). 
#' @exportS3Method summary InteractionClassification
summary.InteractionClassification <- function(object, ...) {
  group_means <- 
    magrittr::`%>%`(magrittr::`%>%`(object, dplyr::group_by(classification)),
                    dplyr::summarise(
                      cds_diff_mean = mean(cds3_diff), 
                      vlogs_diff_mean = mean(vlogs3_diff), 
                      n = dplyr::n(),
                      .groups = 'drop'
                    )) 
  class(group_means) <- c("summary.InteractionClassification", "data.frame")
  
  return(group_means)
}

utils::globalVariables(c("classification", "cds3_diff", "vlogs3_diff", "cds_diff_mean", "vlogs_diff_mean"))