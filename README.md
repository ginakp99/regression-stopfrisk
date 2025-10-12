# Detecting Racial Bias in Stop-and-Frisk (NYC 2003 – 2013)

**Goal:** Investigate whether the likelihood of police using force during Stop-and-Frisk incidents depends on civilian race,  
after controlling for demographic and contextual factors.

Developed for the *Regression* course, University of Copenhagen (2023).  
Demonstrates applied skills in **statistical modeling**, **data ethics**, and **reproducible analysis**.

---

## 📊 Dataset
New York City Stop-and-Frisk data (~5 million records, 2003–2013).  
Key variables:  
`force`, `race2`, `gender`, `age2`, `daytime`, `ac_incid`, `ac_time`, `inout2`, `offunif2`.

**Outcome:** `force > 0` → 1 if force used, 0 otherwise.  
**Focus:** Detect racial disparities in use of force.

---

## 🧠 Methods
- Exploratory Data Analysis (EDA)
- Missing data handled with **Multiple Imputation by Chained Equations (MICE)**
- Logistic Regression  
  \[
  \text{logit}(p_i)=\beta_0+\beta_1\text{race}_i+\beta_2\text{gender}_i+\beta_3\text{age}_i+\dots
  \]
- Model selection by AIC, validation via 80/20 split  
- Diagnostics using **DHARMa**  
- Interaction term `race × daytime`

---

## 📈 Results
| Variable | Interpretation |
|-----------|----------------|
| **Black / Hispanic** | Higher odds of force use vs White baseline |
| **Female** | Lower probability of force |
| **High-crime area/time** | Strong positive association with force |

**AUC ≈ 0.74** → good model discrimination.  
**Conclusion:** Racial disparities persist even after adjustment for confounders.

---

## 🧰 Tools
R · MICE · ggplot2 · DHARMa · dplyr · broom

---

## 📂 Repository Structure
