# load required packages ----
if (!require("pacman")) install.packages("pacman") 
pacman::p_load(readr, usethis, here)

# clean data ----
qphen <- readr::read_csv(here::here("data-raw","qphen.csv"))

# write data in correct format to data folder ----
usethis::use_data(qphen, overwrite = TRUE)