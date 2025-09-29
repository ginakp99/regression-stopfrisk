# -------------------------------------------------------------------
# data_cleaning.R
# Stop & Frisk – Portfolio-friendly data preparation
# Author: Georgia-Olga Kalapotharakou
#
# Purpose:
# - Generate a small synthetic dataset (safe for public GitHub)
# - Apply light cleaning and type harmonization
# - Save clean data for downstream regression scripts
#
# Output:
# - data/clean/clean_demo.csv
# -------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(forcats)
  library(tidyr)
})

# Create output folder (relative path, safe for GitHub)
dir.create("data/clean", recursive = TRUE, showWarnings = FALSE)

# ===========================
# SYNTHETIC DATA
# ===========================
# Why: recruiters can run the project immediately without large/sensitive files.
set.seed(42)

n <- 2000
demo <- tibble(
  # Binary outcome used in the report: any force vs no force
  new_force = rbinom(n, size = 1, prob = 0.22),      # ~22% “any force”
  # Predictors
  race2     = sample(c("white","black","hispanic","asian","other"),
                     size = n, replace = TRUE,
                     prob = c(0.25,0.35,0.30,0.05,0.05)),
  age2      = pmin(pmax(round(rnorm(n, mean = 31, sd = 10)), 14), 70),
  gender    = sample(c("male","female"), size = n, replace = TRUE,
                     prob = c(0.82,0.18)),
  ac_incid  = sample(c("N","Y"), size = n, replace = TRUE, prob = c(0.45,0.55)),  # high-crime area
  cs_vcrim  = sample(c("N","Y"), size = n, replace = TRUE, prob = c(0.60,0.40))   # violent-crime reason
)

# Introduce a few NAs to resemble real-world data
demo$age2[sample.int(n, size = floor(0.03 * n))] <- NA_integer_

# Clean + type harmonization
clean_demo <- demo %>%
  mutate(
    race2     = factor(race2, levels = c("white","black","hispanic","asian","other")),
    gender    = factor(gender, levels = c("male","female")),
    ac_incid  = factor(ac_incid, levels = c("N","Y")),
    cs_vcrim  = factor(cs_vcrim, levels = c("N","Y")),
    new_force = factor(new_force, levels = c(0,1))   # 0=no force, 1=any force
  ) %>%
  drop_na(age2)  # keep it simple for portfolio (you can swap to imputation later)

# Save synthetic clean data
write_csv(clean_demo, "data/clean/clean_demo.csv")
message("Wrote: data/clean/clean_demo.csv (synthetic, safe for public repos)")

# End of script
