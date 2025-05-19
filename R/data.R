#' Longitudinal CD4 Lymphocyte Counts for HIV Patients (2018-2024)
#'
#' @description Contains longitudinal measurements of CD4 lymphocyte counts for 
#' 176 patients living with HIV, recorded over the period from 2018 to 2024. 
#' CD4 counts are a critical indicator of immune function, used to monitor the 
#' progression of HIV and the effectiveness of treatments. Measurements were 
#' taken at various points throughout the study, with some missing values due 
#' to unavailable data for specific patients at certain times.
#'
#' @format A data frame with 176 rows and 18 variables:
#' \describe{
#'   \item{ID}{Unique identifier for each patient.}
#'   \item{cd_2018_1}{CD4 count for the first measurement in 2018.}
#'   \item{cd_2018_2}{CD4 count for the second measurement in 2018.}
#'   \item{cd_2019_1}{CD4 count for the first measurement in 2019.}
#'   \item{cd_2019_2}{CD4 count for the second measurement in 2019.}
#'   \item{cd_2020_1}{CD4 count for the first measurement in 2020.}
#'   \item{cd_2021_1}{CD4 count for the first measurement in 2021.}
#'   \item{cd_2021_2}{CD4 count for the second measurement in 2021.}
#'   \item{cd_2021_3}{CD4 count for the third measurement in 2021.}
#'   \item{cd_2022_1}{CD4 count for the first measurement in 2022.}
#'   \item{cd_2022_2}{CD4 count for the second measurement in 2022.}
#'   \item{cd_2022_3}{CD4 count for the third measurement in 2022.}
#'   \item{cd_2023_1}{CD4 count for the first measurement in 2023.}
#'   \item{cd_2023_2}{CD4 count for the second measurement in 2023.}
#'   \item{cd_2023_3}{CD4 count for the third measurement in 2023.}
#'   \item{cd_2024_1}{CD4 count for the first measurement in 2024.}
#'   \item{cd_2024_2}{CD4 count for the second measurement in 2024.}
#'   \item{cd_2024_3}{CD4 count for the third measurement in 2024.}
#' }
#'
#' @details .
#' CD4 counts are used to monitor immune system health in individuals with 
#' HIV. A lower CD4 count often indicates a weakened immune system, whereas 
#' higher counts suggest a stronger immune response. Some values are missing, 
#' indicating no measurement was taken for a particular patient at that time.
#'
#' @examples
#' # Load the dataset
#' data(cd_3)
#'
#' # Summarize CD4 counts for the year 2021
#' summary(cd_3[, c("cd_2021_1", "cd_2021_2", "cd_2021_3")])
#'
#' @source Clinical data from Hospital Vicente Guerrero, IMSS, HIV Clinic.
"cd_3"


#' Longitudinal Viral Load Values for HIV Patients (2018-2024)
#'
#' @description Contains longitudinal measurements of viral load for 176 
#' patients from 2018 to 2024. Viral load is a critical marker used to monitor 
#' the effectiveness of HIV treatment by measuring the amount of HIV RNA in the 
#' blood.
#'
#' @format A data frame with 176 rows and 18 variables:
#' \describe{
#'   \item{ID}{Unique identifier for each patient.}
#'   \item{vl_2018_1}{Viral load for the first measurement in 2018.}
#'   \item{vl_2018_2}{Viral load for the second measurement in 2018.}
#'   \item{vl_2019_1}{Viral load for the first measurement in 2019.}
#'   \item{vl_2019_2}{Viral load for the second measurement in 2019.}
#'   \item{vl_2020_1}{Viral load for the first measurement in 2020.}
#'   \item{vl_2021_1}{Viral load for the first measurement in 2021.}
#'   \item{vl_2021_2}{Viral load for the second measurement in 2021.}
#'   \item{vl_2021_3}{Viral load for the third measurement in 2021.}
#'   \item{vl_2022_1}{Viral load for the first measurement in 2022.}
#'   \item{vl_2022_2}{Viral load for the second measurement in 2022.}
#'   \item{vl_2022_3}{Viral load for the third measurement in 2022.}
#'   \item{vl_2023_1}{Viral load for the first measurement in 2023.}
#'   \item{vl_2023_2}{Viral load for the second measurement in 2023.}
#'   \item{vl_2023_3}{Viral load for the third measurement in 2023.}
#'   \item{vl_2024_1}{Viral load for the first measurement in 2024.}
#'   \item{vl_2024_2}{Viral load for the second measurement in 2024.}
#'   \item{vl_2024_3}{Viral load for the third measurement in 2024.}
#' }
#'
#' @details
#' The viral load measurements provide insight into the patient's response to 
#' antiretroviral therapy (ART). Lower viral load values, especially 
#' undetectable levels, indicate better control of the infection. Missing 
#' values indicate that no viral load measurement was available for that patient 
#' at that specific time.
#'
#' @examples
#' \dontrun{
#' # Load the dataset
#' data(vl_3)
#'
#' # Summarize viral loads for the year 2021
#' summary(vl_3[, c("cd_2021_1", "cd_2021_2", "cd_2021_3")])
#' }
#'
#' @source Clinical data from Hospital Vicente Guerrero, IMSS, HIV Clinic.
"vl_3"


#' Quantum Phenotype Interactions in HIV Model
#'
#' The `qphen` dataset contains 176 observations and 24 variables, representing classified phenotype interactions in a quantum game-theoretic model of HIV phenotypes.
#' The data includes CD4 and viral load differences, quantum game strategies, classification clusters, and tuberculosis/genoresistance indicators.
#'
#' @format A data frame with 176 rows and 24 variables:
#' \describe{
#'   \item{id}{(double) Unique identifier for each observation.}
#'   \item{vl_diff}{(double) Difference in viral load (log scale) between time points.}
#'   \item{cd_diff}{(double) Difference in CD4 count between time points.}
#'   \item{vlogs_diff_mean}{(double) Mean difference of viral loads across the dataset.}
#'   \item{cds_diff_mean}{(double) Mean difference of CD4 counts across the dataset.}
#'   \item{n}{(double) Number of cases in each interaction cluster.}
#'   \item{payoffs}{(double) Computed payoff for the phenotype interaction.}
#'   #'   \item{payoffs_b}{(double) Alternative computed payoff.}
#'   \item{nearest_payoff}{(double) Closest estimated payoff value.}
#'   \item{classification_2}{(double) Cluster assignment for phenotype interactions (second clustering method).}
#'   \item{classification_3}{(double) Cluster assignment for phenotype interactions (third clustering method).}
#'   \item{classification_4}{(double) Cluster assignment for phenotype interactions (fourth clustering method).}
#'   \item{phen_1}{(double) Phenotype type (`v` or `V`).}
#'   \item{str1_2}{(double) Strategy of the first phenotype using `X`, `T`, or `H` gate (binary encoding).}
#'   \item{str1_3}{(double) Alternative strategy of the first phenotype.}
#'   \item{str2_2}{(double) Strategy of the second phenotype using `H`, `Id`, `S`, `T`, `X`, `Y`, or `Z` gate (binary encoding).}
#'   \item{str2_3}{(double) Alternative strategy of the second phenotype.}
#'   \item{str2_4}{(double) Alternative strategy of the second phenotype.}
#'   \item{str2_5}{(double) Alternative strategy of the second phenotype.}
#'   \item{str2_6}{(double) Alternative strategy of the second phenotype.}
#'   \item{str2_7}{(double) Alternative strategy of the second phenotype.}
#'   \item{batch_1}{(double) Indicates whether predictions were made on full data or batch data.}
#'   \item{TB_1}{(double) Indicator for tuberculosis presence (1 = TB, 0 = no TB).}
#'   \item{GR_1}{(double) Indicator for genoresistance presence (1 = resistant, 0 = non-resistant).}
#' }
#'
#' @usage data(qphen)
#'
#' @keywords datasets
#'
#' @examples
#' data(qphen)
#' head(qphen)
"qphen"


#' Predictions for Longitudinal Viral Load Values for HIV Patients (2018-2024)
#'
#' @description Contains predictions of longitudinal viral load values for 176 
#' patients from 2018 to 2024. 
#'
#' @examples
#' data(preds)
#' head(preds)
#'
#' @source Clinical data from Hospital Vicente Guerrero, IMSS, HIV Clinic.
"preds"


#' Batched Predictions for Longitudinal Viral Load Values for HIV Patients (2018-2024)
#'
#' @description Contains batched predictions of longitudinal viral load values for 176 
#' patients from 2018 to 2024. 
#'
#' @examples
#' data(preds2)
#' head(preds2)
#'
#' @source Clinical data from Hospital Vicente Guerrero, IMSS, HIV Clinic.
"preds2"
