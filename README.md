# Detecting Racial Bias in Stop-and-Frisk (NYC 2003–2013)

**Goal:** Investigate whether the likelihood of police using force during Stop-and-Frisk incidents depends on civilian race,  
after controlling for demographic and contextual factors.

This repository presents my personal analysis based on a group project from the *Regression* course, University of Copenhagen (2023).  
It focuses on my individual contributions: data preprocessing, multiple imputation, model design, diagnostics, and interpretation.

---

## Dataset
NYC Stop-and-Frisk (~5 million observations, 2003–2013).  
Key variables: `force`, `race2`, `gender`, `age2`, `daytime`, `ac_incid`, `ac_time`, `inout2`, `offunif2`.

**Outcome:** `force > 0` → 1 if force used, 0 otherwise.  
**Focus:** Detect racial disparities in the use of police force.

---

## Methods
- Exploratory Data Analysis (EDA)
- Missing data handled with **Multiple Imputation by Chained Equations (MICE, PMM)**
- Logistic Regression with interaction term `race × daytime`
- Model selection by **AIC**
- Diagnostics with **DHARMa** residual tests
- Validation by **ROC curve (AUC ≈ 0.74)**

---

## Results
| Variable | Interpretation |
|-----------|----------------|
| **Black / Hispanic** | Higher odds of force use vs. White baseline |
| **Female** | Lower probability of force |
| **High-crime area/time** | Positive association with force use |

**Conclusion:** Racial disparities persist even after adjustment for confounders.

---

## Visualizations
*(Example placeholders — upload your own images to `/figures`)*

![Odds Ratios](figures/odds_ratios.png)  
*Estimated odds ratios with 95% confidence intervals.*

![ROC Curve](figures/roc_curve.png)  
*ROC curve showing model discrimination (AUC ≈ 0.74).*

---

## Tools
R · MICE · ggplot2 · DHARMa · dplyr · broom

---

## Repository Structure

-code/ → R scripts (data prep, imputation, model, diagnostics)
-figures/ → key visualizations
-report/ → short summary PDF
-README.md → this file


---

## My Contributions
- Designed and implemented **multiple imputation** workflow (`mice`, PMM)
- Built and validated **logistic regression** model with interactions
- Produced **diagnostics (DHARMa)** and ROC curve
- Wrote **interpretation** and fairness discussion

---

## Key Takeaways
- Worked with a **large, real-world dataset**  
- Applied **statistical reasoning** to detect bias and ensure fairness  
- Communicated uncertainty & model assumptions clearly  
- Practiced **ethical and reproducible ML analysis**

---

[Download short project summary (PDF)](report/summary_stopfrisk_Gina.pdf)  
**Portfolio:** [ginakp99.github.io](https://ginakp99.github.io/)

---

🛡️ **Copyright Notice**

© 2025 Georgia-Olga Kalapotharakou.  
All rights reserved. Shared for educational and portfolio purposes only.

---

**Tags:** Regression · Fairness · Bias Detection · MICE · R · DHARMa · Statistical Modeling

