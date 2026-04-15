# load required packages ----
if (!require("pacman")) install.packages("pacman") 
pacman::p_load(readr, usethis, here)

# clean data ----
data_enc <- readr::read_csv(here::here("data-raw","data_enc.csv"))

# write data in correct format to data folder ----
usethis::use_data(data_enc, overwrite = TRUE)