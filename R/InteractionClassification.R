#' Classify HIV phenotype interactions using k-means clustering
#'
#' This function performs k-means clustering on the differences in viral load and CD4 counts
#' to classify interaction types between HIV phenotypes. It returns an object of class
#' `InteractionClassification`, a `data.frame` with classification labels.
#'
#' @param cd_result A numeric vector of differences in CD4 T-cell counts.
#' @param vl_result A numeric vector of differences in log viral load.
#' @param k Integer. The number of clusters to use in k-means. Default is 4.
#' @param ns Integer. Number of random initializations for the k-means algorithm. Default is 100.
#' @param seed Integer. Seed for random number generation to ensure reproducibility. Default is 123.
#'
#' @returns A `data.frame` of class `InteractionClassification` with three columns:
#' \describe{
#'   \item{cds3_result}{The CD4 count difference for each interaction.}
#'   \item{vlogs3_result}{The viral load difference (log scale) for each interaction.}
#'   \item{classification}{An integer label (1 to `k`) indicating the interaction cluster.}
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
InteractionClassification <- function(cd_result, vl_result, k = 4, ns = 100, seed = 123) {
  set.seed(seed)
  
  # Crear data frame con diferencias
  diffs <- data.frame(cd_result = cd_result, vl_result = vl_result)
  
  # Ejecutar k-means
  km_res <- stats::kmeans(diffs, centers = k, nstart = ns)
  
  # Crear objeto con clase personalizada
  classification_result <- data.frame(cd_result = cd_result, vl_result = vl_result, classification = as.factor(km_res$cluster))
  
  class(classification_result) <- c("InteractionClassification", "data.frame")
  
  return(classification_result)
}