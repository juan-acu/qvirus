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


#' Angle-Encoding Dataset for 3-Qubit Quantum State Preparation
#'
#' @description A numeric data frame containing patient-level biomarker expression values
#' used for angle encoding into a 3-qubit quantum state. Each row corresponds
#' to a sample (patient), and each column corresponds to a biomarker mapped
#' to a rotation angle in the quantum circuit.
#'
#' @details
#' The encoding follows a 3-qubit angle encoding scheme:
#'
#' \deqn{
#' |\psi_j\rangle = \bigotimes_{i=1}^3 R_y(\theta_{j,i}) R_z(\phi_{j,i}) |0\rangle
#' }
#'
#' where each qubit is parameterized by two biomarkers:
#'
#' \itemize{
#'   \item \strong{Qubit 1:} \code{IL6} (\eqn{\theta_1}), \code{IDO1} (\eqn{\phi_1})
#'   \item \strong{Qubit 2:} \code{TDO2} (\eqn{\theta_2}), \code{CD14} (\eqn{\phi_2})
#'   \item \strong{Qubit 3:} \code{HADH} (\eqn{\theta_3}), \code{LDHB} (\eqn{\phi_3})
#' }
#'
#' These biomarkers capture key immunometabolic axes, including inflammation,
#' tryptophan metabolism, innate immune sensing, and metabolic reprogramming.
#'
#' Prior to encoding, values are typically normalized to angular ranges
#' (e.g., \eqn{[0, 2\pi]}) using dataset-specific min–max scaling.
#'
#' @format A data frame with 12 rows and 6 variables:
#' \describe{
#'   \item{CD14}{Expression level of CD14 (innate immune receptor; phi2 angle).}
#'   \item{HADH}{Expression level of HADH (beta-oxidation marker; theta3 angle).}
#'   \item{IDO1}{Expression level of IDO1 (tryptophan metabolism; phi1 angle).}
#'   \item{IL6}{Expression level of IL6 (inflammatory signaling; theta1 angle).}
#'   \item{LDHB}{Expression level of LDHB (glycolytic flux; phi3 angle).}
#'   \item{TDO2}{Expression level of TDO2 (systemic metabolic repression; theta2 angle).}
#' }
#'
#' @usage data(data_enc)
#'
#' @examples
#' data(data_enc)
#' str(data_enc)
#'
#' @references
#' Brown, A. J., et al. (2024). Metabolic reprogramming of human macrophages during Mycobacterium tuberculosis infection under HIV exposure. Gene Expression Omnibus (GEO), accession GSE314344.
#' Baluku, J. B., et al. (2023). DNA methylation profiling of people living with HIV stratified by tuberculosis status. Gene Expression Omnibus (GEO), accession GSE304107.
#'
"data_enc"


#' Biomarker Correlation Dataset for Hamiltonian Construction
#'
#' @description A numeric data frame containing a curated panel of biomarkers used to
#' estimate correlation-driven coefficients for a variational Hamiltonian
#' in a 3-qubit quantum model.
#'
#' @details
#' The Hamiltonian is defined as:
#'
#' \deqn{
#' \hat{H} = \sum_{k=1}^K c_k P_k
#' }
#'
#' where:
#' \itemize{
#'   \item \eqn{P_k} are Pauli strings from the 3-qubit Pauli group
#'   \item \eqn{c_k} are coefficients estimated via Pearson correlation
#'   between selected biomarkers
#' }
#'
#' The biomarkers in \code{data_corr} are grouped into biological axes:
#'
#' \itemize{
#'   \item \strong{Amino Acid Metabolism:} IDO1, TDO2, ACMSD, CPS1, FAH
#'   \item \strong{Immune Signaling:} IL6, CCL4, CCL5, CCL13, NT5E
#'   \item \strong{Antigen Processing:} CD14, CD163, LAT, CTSL, CTSD
#'   \item \strong{Fatty Acid / Lipid:} HADH, FASN, LTC4S, PTGS2, PTGES
#'   \item \strong{Aerobic / Nucleotide:} LDHB, PKM, IMPDH2, ADA, ADK, HK2
#'   \item \strong{Regulatory / Epigenetic:} ZNF93, MTF1, RPTOR, ZNF708, CAD
#' }
#'
#' These features define a high-dimensional correlation structure used to
#' construct patient-specific or cohort-level Hamiltonians.
#'
#' @format A data frame with 12 rows and 30 variables:
#' \describe{
#'   \item{ACMSD}{Amino acid metabolism biomarker.}
#'   \item{ADA}{Nucleotide metabolism enzyme.}
#'   \item{ADK}{Adenosine kinase (nucleotide metabolism).}
#'   \item{CCL13}{Chemokine involved in immune signaling.}
#'   \item{CCL4}{Inflammatory chemokine.}
#'   \item{CCL5}{Immune signaling chemokine.}
#'   \item{CD14}{Innate immune receptor.}
#'   \item{CD163}{Macrophage activation marker.}
#'   \item{CPS1}{Urea cycle enzyme.}
#'   \item{CTSD}{Lysosomal protease.}
#'   \item{CTSL}{Cathepsin L (antigen processing).}
#'   \item{FAH}{Fumarylacetoacetate hydrolase.}
#'   \item{FASN}{Fatty acid synthase.}
#'   \item{HADH}{Beta-oxidation enzyme.}
#'   \item{HK2}{Hexokinase 2 (glycolysis).}
#'   \item{IDO1}{Tryptophan metabolism enzyme.}
#'   \item{IL6}{Inflammatory cytokine.}
#'   \item{IMPDH2}{Purine biosynthesis enzyme.}
#'   \item{LAT}{T-cell activation linker protein.}
#'   \item{LDHB}{Lactate dehydrogenase B.}
#'   \item{LTC4S}{Leukotriene synthesis enzyme.}
#'   \item{MTF1}{Metal regulatory transcription factor.}
#'   \item{NT5E}{Ecto-5'-nucleotidase.}
#'   \item{PKM}{Pyruvate kinase (glycolysis).}
#'   \item{PTGES}{Prostaglandin synthesis enzyme.}
#'   \item{PTGS2}{Cyclooxygenase-2 (inflammation).}
#'   \item{RPTOR}{mTOR pathway regulator.}
#'   \item{TDO2}{Tryptophan metabolism enzyme.}
#'   \item{ZNF708}{Zinc finger transcription factor.}
#'   \item{ZNF93}{Zinc finger regulatory protein.}
#' }
#'
#' @usage data(data_corr)
#'
#' @examples
#' data(data_corr)
#' dim(data_corr)
#' 
#' @references
#' Brown, A. J., et al. (2024). Metabolic reprogramming of human macrophages during Mycobacterium tuberculosis infection under HIV exposure. Gene Expression Omnibus (GEO), accession GSE314344.
#' Baluku, J. B., et al. (2023). DNA methylation profiling of people living with HIV stratified by tuberculosis status. Gene Expression Omnibus (GEO), accession GSE304107.
#'
"data_corr"
