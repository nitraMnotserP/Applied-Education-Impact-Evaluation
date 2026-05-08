# Applied Education Data Analysis: Measurement, Longitudinal, Multilevel, and Survey‑Based Approaches

This repository contains selected, anonymized code from applied education
research and analysis projects. The analyses demonstrate how **measurement
modeling**, **longitudinal analysis**, **multilevel modeling**, and
**design‑based survey methods** can be combined to study educational processes
and outcomes using administrative and large‑scale survey data.

Projects span program evaluation, observational research, and policy‑relevant
analysis. All identifying details, program names, and data paths have been
anonymized to protect confidentiality.

---

## Portfolio Overview

Applied education research frequently relies on complex, non‑experimental data
sources in which:

- Students are not randomly assigned to programs or experiences  
- Outcomes are observed repeatedly over time  
- Students may be taught by multiple instructors within a school year  
- Assessments are scored by different raters or observers  
- Data arise from complex survey designs with unequal selection probabilities  
- School and classroom contexts introduce meaningful clustering  

This repository presents analytic workflows designed to address these
real‑world complexities while producing transparent, defensible, and
policy‑relevant insights.

Across analyses, the overarching goal is to make analytic assumptions explicit
and to align modeling choices with the structure of the data.

---

## Analytic Framework

Four complementary analytic approaches are represented in this repository.
Each addresses a common challenge in applied education research and analytics.

---

### 1. Multilevel Analysis: Multiple‑Membership Models

One set of analyses addresses instructional complexity in educational settings
where students are taught by **more than one teacher** within a given period.

These analyses emphasize:

- Multiple‑membership multilevel models to account for shared instructional
  influence across teachers
- Variance partitioning to assess teacher‑level contributions to student
  outcomes
- Fixed effects for student‑ and school‑level covariates when cluster sizes are
  small
- Estimation of effects under realistic teacher assignment structures

This approach is especially well‑suited for cumulative outcomes (such as GPA)
and for analyses where attributing outcomes to a single instructor would be
misleading.

---

### 2. Measurement‑Focused Analysis: Many‑Facet Rasch Models

A second set of analyses focuses on **assessment measurement and rater effects**
in contexts where student performance is evaluated by multiple observers across
time.

These analyses emphasize:

- Many‑Facet Rasch Models (MFRM) to adjust scores for:
  - Item difficulty  
  - Rating scale structure  
  - Rater severity and rater‑by‑item interactions  
- Separate model estimation for pre‑ and post‑observation waves
- Diagnostic evaluation using:
  - Fit statistics  
  - Threshold estimates  
  - Wright Maps and characteristic curves  
- Extraction of rater‑adjusted ability estimates for downstream analysis

This measurement step helps ensure that observed differences reflect meaningful
variation in student performance rather than artifacts of rater behavior or
instrument design.

---

### 3. Longitudinal Analysis: Latent Growth Curve Modeling

A third set of analyses focuses on **student achievement trajectories measured
over time**, with attention to how educational experiences relate to both
initial status and change.

Key features include:

- Repeated outcome measurement across multiple time points
- Latent Growth Curve Models (LGCMs) estimated via structural equation modeling
- Linear growth specified across observation periods
- Effects estimated on:
  - The **intercept** (baseline performance)
  - The **slope** (rate of change over time)
- Full Information Maximum Likelihood (FIML) used to address missing data under a
  Missing at Random (MAR) assumption

These models are used both descriptively and in combination with design‑based
approaches to support causal interpretation where appropriate.

---

### 4. Design‑Based Survey Analysis: Complex Survey Data

A fourth set of analyses demonstrates the use of **nationally representative
education survey data**, incorporating survey design features directly into
estimation and inference.

These analyses emphasize:

- Use of replicate‑weight variance estimation (e.g., BRR)
- Integration of multiple imputation with survey design objects
- Design‑based generalized linear models
- Estimation of marginal effects on interpretable probability scales
- Subpopulation analyses conducted within the survey framework

This approach is critical when working with large‑scale federal datasets (such
as NCES longitudinal studies) where valid inference depends on respecting the
sampling design.

---

## Shared Analytic Principles Across Projects

Despite methodological differences, all analyses in this repository share a
common set of principles.

### Data Integration and Preparation
- Student‑level administrative records spanning multiple cohorts
- Assessment data scored by multiple raters across observation waves
- Large‑scale survey data with complex sampling designs
- Publicly available school‑level contextual data (e.g., NCES indicators)
- Careful harmonization of variables across sources and time

### Design and Modeling Transparency
- Clear separation of:
  - Measurement
  - Design
  - Outcome modeling
- Explicit documentation of assumptions
- Diagnostic checks aligned with each analytic approach

### Equity‑Relevant Covariates
- Attendance and discipline indicators
- Student demographic characteristics
- Socioeconomic context at the student and school level

---

## Why These Analyses Matter

Educational data rarely conform to the assumptions of simple statistical models.
Ignoring measurement error, clustering, time, or survey design can lead to
misleading conclusions.

Together, the **measurement models**, **longitudinal models**, **multilevel
models**, and **design‑based survey analyses** in this repository demonstrate
how applied analysts can:

- Align analytic methods with data structure
- Address complexity directly rather than through ad‑hoc adjustments
- Produce results that are both methodologically sound and practically useful
for research, evaluation, and policy contexts

---

## Notes on Reproducibility and Use

- All data paths have been replaced with placeholders
- Sensitive variables, identifiers, and program names have been anonymized
- Code is provided to demonstrate analytic structure, documentation practices,
  and methodological approach
- Scripts are not intended to be fully reproducible without access to the
  original restricted data

---

## Contact

**Preston Martin, Ph.D.**  
Applied Learning Scientist & Education Data Analyst  

- LinkedIn: https://www.linkedin.com/in/prestonmartin1  
- GitHub: https://github.com/nitraMnotserP
