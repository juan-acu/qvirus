# load required packages ----
if (!require("pacman")) install.packages("pacman") 
pacman::p_load(readr, usethis, here)

# clean data ----
preds <- readr::read_csv(here::here("data-raw","preds.csv"))

# write data in correct format to data folder ----
usethis::use_data(preds, overwrite = TRUE)