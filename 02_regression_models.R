# -------------------------------------------------------------------
# regression_models.R
# Stop & Frisk – Logistic regression (main, interaction, splines)
# Author: Georgia-Olga Kalapotharakou
#
# Purpose:
# - Fit logistic regression variants:
#     m1: main effects
#     m2: race × high-crime area interaction
#     m3: main effects + spline for age (ns(age2, df = 3))
# - Compare with AIC, McFadden pseudo-R^2, and 10-fold CV log-loss
# - Save:
#     (a) coefficient plot for m2 (interaction model)
#     (b) age partial-effect plot: linear (m1) vs spline (m3)
#
# Inputs:
# - data/clean/clean_demo.csv (from scripts/data_cleaning.R)
#
# Outputs:
# - figures/coefficients_plot.png
# - figures/age_effect_linear_vs_spline.png
# -------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(ggplot2)
  library(broom)
  library(splines)  # ns()
  library(boot)     # cv.glm
  library(forcats)
})

# ---- Load data ----
dat_path <- "data/clean/clean_demo.csv"
stopifnot(file.exists(dat_path))

dat <- read_csv(dat_path, show_col_types = FALSE) %>%
  mutate(across(c(new_force, race2, gender, ac_incid, cs_vcrim), as.factor))

# Ensure outcome has levels 0/1 (as characters) for stable conversions
if (!all(levels(dat$new_force) %in% c("0","1"))) {
  dat$new_force <- factor(dat$new_force, levels = c("0","1"))
}

# ---- Model formulas ----
f_main   <- new_force ~ race2 + age2 + gender + ac_incid + cs_vcrim
f_inter  <- new_force ~ race2 * ac_incid + age2 + gender + cs_vcrim
f_spline <- new_force ~ race2 + ns(age2, df = 3) + gender + ac_incid + cs_vcrim

# ---- Fit models ----
m1 <- glm(f_main,   data = dat, family = binomial())
m2 <- glm(f_inter,  data = dat, family = binomial())
m3 <- glm(f_spline, data = dat, family = binomial())

# ---- AIC & McFadden pseudo-R^2 ----
m0 <- glm(new_force ~ 1, data = dat, family = binomial())
pseudoR2 <- function(m, m_null = m0) 1 - as.numeric(logLik(m) / logLik(m_null))

aic_tbl <- tibble(
  model    = c("m1_main", "m2_interaction", "m3_spline"),
  AIC      = c(AIC(m1), AIC(m2), AIC(m3)),
  pseudoR2 = c(pseudoR2(m1), pseudoR2(m2), pseudoR2(m3))
)

cat("\nAIC & McFadden pseudo-R^2\n")
print(aic_tbl)

# ---- 10-fold CV log-loss using boot::cv.glm ----
logloss_cost <- function(y, p) {
  eps <- 1e-12
  p <- pmin(pmax(p, eps), 1 - eps)
  -mean(y * log(p) + (1 - y) * log(1 - p))
}

cv_logloss <- function(data, formula, K = 10) {
  gfit <- glm(formula, data = data, family = binomial())
  # cost gets r = response vector; convert factor "0"/"1" -> numeric 0/1
  cost_fun <- function(r, pi) {
    y <- as.numeric(as.character(r))
    logloss_cost(y, pi)
  }
  res <- boot::cv.glm(data = data, glmfit = gfit, cost = cost_fun, K = K)
  as.numeric(res$delta[1])  # K-fold estimate
}

set.seed(123)
cv_tbl <- tibble(
  model   = c("m1_main", "m2_interaction", "m3_spline"),
  logloss = c(
    cv_logloss(dat, f_main,   K = 10),
    cv_logloss(dat, f_inter,  K = 10),
    cv_logloss(dat, f_spline, K = 10)
  )
)

cat("\n10-fold CV log-loss (lower is better)\n")
print(cv_tbl)

# ---- Coefficient plot for the interaction model (m2) ----
coef_df <- tidy(m2, conf.int = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(term = gsub("race2", "race:", term),
         term = gsub("ac_incid", "area:", term))

p_coef <- ggplot(coef_df, aes(x = estimate, y = reorder(term, estimate))) +
  geom_point() +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  labs(
    title = "Logistic regression coefficients (interaction model)",
    x = "Log-odds (estimate)", y = NULL,
    caption = "Error bars: 95% CI"
  ) +
  theme_minimal(base_size = 12)

dir.create("figures", showWarnings = FALSE)
ggsave("figures/coefficients_plot.png", p_coef, width = 7, height = 6, dpi = 150)

# ---- Age partial-effect plot: linear (m1) vs spline (m3) ----
# Hold other covariates at their empirical modes (most common levels),
# which mirrors a typical conditional effect visualization.

mode_level <- function(f) {
  if (!is.factor(f)) return(NA_character_)
  lvl <- fct_count(f) %>% arrange(desc(n)) %>% slice(1) %>% pull(f)
  as.character(lvl)
}

mode_race   <- mode_level(dat$race2)
mode_gender <- mode_level(dat$gender)
mode_area   <- mode_level(dat$ac_incid)
mode_vcrim  <- mode_level(dat$cs_vcrim)

age_grid <- tibble(age2 = seq(floor(min(dat$age2, na.rm = TRUE)),
                              ceiling(max(dat$age2, na.rm = TRUE)), by = 1)) %>%
  mutate(
    race2   = factor(mode_race,   levels = levels(dat$race2)),
    gender  = factor(mode_gender, levels = levels(dat$gender)),
    ac_incid= factor(mode_area,   levels = levels(dat$ac_incid)),
    cs_vcrim= factor(mode_vcrim,  levels = levels(dat$cs_vcrim))
  )

pred_lin <- age_grid %>%
  mutate(prob = predict(m1, newdata = cur_data(), type = "response"),
         model = "Linear age (m1)")

pred_spl <- age_grid %>%
  mutate(prob = predict(m3, newdata = cur_data(), type = "response"),
         model = "Spline age (m3, df=3)")

pred_df <- bind_rows(pred_lin, pred_spl)

p_age <- ggplot(pred_df, aes(x = age2, y = prob, linetype = model)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Partial effect of age on P(any force)",
    subtitle = paste0(
      "Other covariates fixed at modes: race=", mode_race,
      ", gender=", mode_gender, ", area=", mode_area, ", violent=", mode_vcrim
    ),
    x = "Age", y = "Predicted probability"
  ) +
  theme_minimal(base_size = 12)

ggsave("figures/age_effect_linear_vs_spline.png", p_age, width = 7, height = 5, dpi = 150)

# ---- Summary ----
best_aic     <- aic_tbl$model[which.min(aic_tbl$AIC)]
best_logloss <- cv_tbl$model[which.min(cv_tbl$logloss)]

cat("\n✔ Saved figures:\n")
cat("  - figures/coefficients_plot.png\n")
cat("  - figures/age_effect_linear_vs_spline.png\n")
cat(sprintf("Best by AIC: %s\n", best_aic))
cat(sprintf("Best by 10-fold CV log-loss: %s\n", best_logloss))
# -------------------------------------------------------------------
