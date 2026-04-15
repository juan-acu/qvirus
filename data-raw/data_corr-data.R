# load required packages ----
if (!require("pacman")) install.packages("pacman") 
pacman::p_load(readr, usethis, here)

# clean data ----
data_corr <- readr::read_csv(here::here("data-raw","data_corr.csv"))

# write data in correct format to data folder ----
usethis::use_data(data_corr, overwrite = TRUE)