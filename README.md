# Applied Education Program Evaluation: Multiple Membership Impact Analysis

This repository contains selected, anonymized code from a real K–12 education
program evaluation project. The purpose of the analysis was to estimate the
impact of an educational intervention on student academic outcomes while
accounting for non-random assignment, learner variability, and complex
teacher–student clustering.

The intervention name and all identifying details have been anonymized to
protect confidentiality.

---

## Project Overview

Educational program evaluations often rely on administrative data where
students are exposed to multiple teachers over time and where participation
in interventions is not randomly assigned. This project addresses both
challenges by combining causal matching techniques with multiple-membership
multilevel models.

The primary outcome of interest was students’ overall GPA. Key analytic goals
included:
- Constructing a defensible comparison group using observed covariates
- Assessing balance and overlap between treatment and comparison groups
- Modeling student outcomes while accounting for multiple teachers per student
- Estimating intervention effects under realistic school conditions

---

## Key Methods

This portfolio sample demonstrates the following methods and practices:

- **Data integration and cleaning**
  - Student-level administrative records across multiple cohorts
  - Publicly available school-level contextual data (e.g., NCES indicators)

- **Causal design**
  - Propensity score matching using optimal matching
  - Exact matching on cohort year and grade
  - Balance diagnostics and visualization (e.g., love plots)

- **Multilevel modeling**
  - Multiple-membership random effects models to account for students taught
    by more than one teacher
  - Variance partitioning to assess teacher-level contributions
  - Fixed effects for student- and school-level covariates

- **Equity-relevant covariates**
  - Attendance, discipline, school context, and demographic indicators

---

## Why This Analysis Matters

Many education interventions operate in settings where traditional analytic
assumptions (e.g., single teacher per student, random assignment) do not hold.
This project demonstrates how rigorous yet practical methods can be used to
produce credible evidence under real-world constraints.

The results of this analysis were used to inform program improvement decisions
and to support evidence-based discussions with education stakeholders.

---

## Notes on Reproducibility

- All data paths have been replaced with placeholders
- Sensitive variables and identifiers have been anonymized
- Code is provided for demonstration of analytic approach and structure only

---

## Contact

Preston Martin, Ph.D.  
Applied Learning Scientist & Impact Evaluation Researcher  
LinkedIn: https://www.linkedin.com/in/prestonmartin1  
GitHub: https://github.com/nitraMnotserP
