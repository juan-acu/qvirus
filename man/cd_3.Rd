% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{cd_3}
\alias{cd_3}
\title{Longitudinal CD4 Lymphocyte Counts for HIV Patients (2018-2024)}
\format{
A data frame with 176 rows and 18 variables:
\describe{
\item{ID}{Unique identifier for each patient.}
\item{cd_2018_1}{CD4 count for the first measurement in 2018.}
\item{cd_2018_2}{CD4 count for the second measurement in 2018.}
\item{cd_2019_1}{CD4 count for the first measurement in 2019.}
\item{cd_2019_2}{CD4 count for the second measurement in 2019.}
\item{cd_2020_1}{CD4 count for the first measurement in 2020.}
\item{cd_2021_1}{CD4 count for the first measurement in 2021.}
\item{cd_2021_2}{CD4 count for the second measurement in 2021.}
\item{cd_2021_3}{CD4 count for the third measurement in 2021.}
\item{cd_2022_1}{CD4 count for the first measurement in 2022.}
\item{cd_2022_2}{CD4 count for the second measurement in 2022.}
\item{cd_2022_3}{CD4 count for the third measurement in 2022.}
\item{cd_2023_1}{CD4 count for the first measurement in 2023.}
\item{cd_2023_2}{CD4 count for the second measurement in 2023.}
\item{cd_2023_3}{CD4 count for the third measurement in 2023.}
\item{cd_2024_1}{CD4 count for the first measurement in 2024.}
\item{cd_2024_2}{CD4 count for the second measurement in 2024.}
\item{cd_2024_3}{CD4 count for the third measurement in 2024.}
}
}
\source{
Clinical data from Hospital Vicente Guerrero, IMSS, HIV Clinic.
}
\usage{
cd_3
}
\description{
Contains longitudinal measurements of CD4 lymphocyte counts for
176 patients living with HIV, recorded over the period from 2018 to 2024.
CD4 counts are a critical indicator of immune function, used to monitor the
progression of HIV and the effectiveness of treatments. Measurements were
taken at various points throughout the study, with some missing values due
to unavailable data for specific patients at certain times.
}
\details{
.
CD4 counts are used to monitor immune system health in individuals with
HIV. A lower CD4 count often indicates a weakened immune system, whereas
higher counts suggest a stronger immune response. Some values are missing,
indicating no measurement was taken for a particular patient at that time.
}
\examples{
# Load the dataset
data(cd_3)

# Summarize CD4 counts for the year 2021
summary(cd_3[, c("cd_2021_1", "cd_2021_2", "cd_2021_3")])

}
\keyword{datasets}
