# load required packages ----
if (!require("pacman")) install.packages("pacman") 
pacman::p_load(readr, usethis, here)

# clean data ----
cd_3 <- readr::read_csv(here::here("data-raw","cd_3.csv"))

# write data in correct format to data folder ----
usethis::use_data(cd_3, overwrite = TRUE)