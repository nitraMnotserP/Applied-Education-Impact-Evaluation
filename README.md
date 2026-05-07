# Applied Education Program Evaluation: Longitudinal, and Multilevel Analyses

This repository contains selected, anonymized code from real K–12 education
program evaluation projects. The analyses demonstrate how rigorous causal
designs can be combined with **longitudinal growth modeling** and **multilevel
multiple‑membership models** to evaluate educational interventions using
administrative data.

All intervention names and identifying details have been anonymized to protect
confidentiality.

---

## Project Overview

Educational program evaluations frequently rely on observational administrative
data in which:

- Students are not randomly assigned to interventions  
- Outcomes are observed repeatedly over time  
- Students may be taught by multiple instructors within a school year  
- School and classroom contexts introduce meaningful clustering  

This repository presents applied analytic workflows designed to address these
real‑world constraints while producing defensible evidence about intervention
effects.

Across analyses, the overarching goal is to estimate credible program impacts
while making assumptions explicit and maintaining transparency in design and
modeling decisions.

---

## Analytic Framework

Two complementary analytic strategies are represented **equally** in this
repository. Each addresses a distinct but common challenge in education
evaluation.

---

### 1. Causal Longitudinal Analysis: Latent Growth Curve Modeling

One set of analyses focuses on **student achievement trajectories measured over
time**, with particular attention to how an intervention influences both initial
status and growth.

Key features of this approach include:

- Quarterly outcome measurement (e.g., Social Studies grades)
- Latent Growth Curve Models (LGCMs) estimated via structural equation modeling
- Linear growth specified across multiple time points
- Intervention effects estimated on:
  - The **intercept** (baseline achievement)
  - The **slope** (rate of academic change over time)
- Full Information Maximum Likelihood (FIML) used to address missing data under a
  Missing at Random (MAR) assumption

Prior to growth modeling, propensity score matching is used to construct a
defensible comparison group and to separate study design from outcome analysis.
Descriptive trajectory plots are examined to assess functional form and guide
model specification.

---

### 2. Causal Multilevel Analysis: Multiple‑Membership Models

A second set of analyses addresses instructional complexity in educational
settings where students are taught by **more than one teacher** within a given
period.

These analyses emphasize:

- Multiple‑membership multilevel models to account for shared instructional
  influence across teachers
- Variance partitioning to assess teacher‑level contributions to student
  outcomes
- Fixed effects for student‑ and school‑level covariates when cluster sizes are
  small
- Estimation of intervention effects under realistic teacher assignment
  structures

This approach is especially well‑suited for cumulative outcomes (such as GPA)
and for evaluations where attributing effects to a single instructor would be
misleading.

---

## Shared Design Elements Across Analyses

Both analytic approaches rely on a common causal design foundation:

### Data Integration and Preparation
- Student‑level administrative records spanning multiple cohorts
- Publicly available school‑level contextual data (e.g., NCES indicators)
- Harmonization of variables across cohorts and data sources

### Causal Design
- Propensity score matching using optimal matching
- Exact matching on cohort year and grade level to enforce overlap
- Balance diagnostics using standardized mean differences
- Visualization of balance via love plots
- Explicit separation of design and outcome modeling stages

### Equity‑Relevant Covariates
- Attendance and discipline indicators
- Student demographic characteristics
- School‑level socioeconomic context (e.g., FRPL, Title I status)

---

## Why These Analyses Matter

Many education interventions are implemented in environments where traditional
analytic assumptions—such as random assignment, independent observations, or
single‑teacher exposure—do not hold.

Together, the longitudinal growth models and multiple‑membership multilevel
models in this repository demonstrate how evaluators can:

- Adapt rigorous methods to administrative data
- Address time, clustering, and instructional complexity directly
- Produce estimates that are both methodologically credible and practically
  useful for decision‑making

Findings from analyses such as these have been used to support program
improvement, stakeholder communication, and evidence‑based policy discussions.

---

## Notes on Reproducibility and Use

- All data paths have been replaced with placeholders
- Sensitive variables and identifiers have been anonymized
- Code is provided to demonstrate analytic structure, documentation practices,
  and methodological approach
- Scripts are not intended to be fully reproducible without access to the
  original restricted data

---

## Contact

**Preston Martin, Ph.D.**  
Applied Learning Scientist & Impact Evaluation Researcher  

- LinkedIn: https://www.linkedin.com/in/prestonmartin1  
- GitHub: https://github.com/nitraMnotserP
``
