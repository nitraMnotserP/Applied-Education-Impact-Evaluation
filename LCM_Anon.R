################################################################################
## Project: Educational Intervention Impact Analysis using Growth Curve Analysis
## Script:  Data Processing, Matching, and Longitudinal Modeling
## Purpose: This script is drawn from a real education program evaluation project.
##          It cleans and integrates student-level administrative data with
##          publicly available school-level data, performs propensity score
##          matching to construct a defensible comparison group, and estimates
##          conditional latent growth curve models for Social Studies Acorss the 
##          academic year.The intervention name has been anonymized as “Intervention”.
## Author:  Preston Martin
## Date:    2026-05-07
################################################################################

##Required Packages:
library(tidyverse) ##Data manipulation & visualization
library(MatchIt) ##Propensity Score Matching 
library(cobalt) ##Assessing covariate balance before and after matching
library(magrittr) ## %<>%
library(lavaan) ##Growth Curve Modeling

##Note: Data paths updated to placeholders for submission.

##NOTE:
## - File paths are placeholders for portfolio submission
## - Sensitive identifiers have been anonymized

################################################################################
## Read in student-level administrative data (three cohorts)
################################################################################

cohort_1 <- haven::read_sav('path/to/cohort_1_Year_1_data.sav')
cohort_2 <- haven::read_sav('path/to/cohort_2_Year_1_data.sav')
cohort_3 <- haven::read_sav('path/to/cohort_3_Year_1_data.sav')

################################################################################
## Read in school-level data (NCES-derived characteristics)
################################################################################

schools <- read_csv('path/to/NCES_data.csv')

################################################################################
## Helper function to harmonize cohort datasets:
##- Aligns variable names
##- Retains analytic variables
##- Converts quarterly grades to numeric
################################################################################

clean_cohort <- function(df) {
  df %<>%
    rename(school_id = school) %>%
    select(
      school_id, staffNumber, studentNumber, Intervention, gender, endYear,
      Q1TermGrade, Q2TermGrade, Q3TermGrade, Q4TermGrade,
      crsName, grade, Overall_GPA, ADA, ODR, studentrace, studentgender
    ) %>%
    mutate(across(starts_with("Q"), as.numeric))
  return(df)
}

##Supply each cohort to function
cohort_1 <- clean_cohort(cohort_1)
cohort_2 <- clean_cohort(cohort_2)
cohort_3 <- clean_cohort(cohort_3)

################################################################################
##Prepare school-level data for merging
################################################################################

schools %<>% 
  rename(school_id = School.Name,
         school_size = `School Size (# of students)`,
         Title_1 = `Title I`,
         stu_tch_ratio = `Student Teacher Ratio`,
         pct_FRPL = `%FRPL`) %>% 
  select(school_id, school_size, Title_1,stu_tch_ratio, pct_FRPL)

################################################################################
## Merge school-level characteristics into cohort datasets
################################################################################

cohort_1 %<>% left_join(schools, by = "school_id")
cohort_2 %<>% left_join(schools, by = "school_id")
cohort_3 %<>% left_join(schools, by = "school_id")

################################################################################
## Integrate cohorts and prepare student-level analytic file
##
## - Cohorts are mutually exclusive and pooled for matching
## - Unit of analysis: student–course observation
## - Quarterly outcomes retained in wide format for growth modeling
################################################################################

student_wide <- bind_rows(cohort_1, cohort_2, cohort_3) %>%
  mutate(
    Intervention = as.factor(Intervention),
    gender = as.factor(gender),
    studentrace = as.factor(studentrace),
    studentgender = as.factor(studentgender),
    endYear = as.factor(endYear),
    Title_1 = as.factor(Title_1),
    ADA = as.numeric(ADA),
    ODR = as.numeric(ODR),
    school_size = as.numeric(school_size),
    stu_tch_ratio = as.numeric(stu_tch_ratio)
  )

################################################################################
## Examine missingness in quarterly grades
################################################################################

student_wide %>%
  mutate(
    n_missing_grades = rowSums(
      is.na(across(c(Q1TermGrade, Q2TermGrade, Q3TermGrade, Q4TermGrade)))
    )
  ) %>%
  group_by(endYear, n_missing_grades) %>%
  summarise(n = n(), .groups = "drop")

################################################################################
##Restrict analytic sample to Social Studies courses
################################################################################

soc_students <- student_wide %>%
  filter(str_detect(crsName, regex("^SOCIAL STUDIES", ignore_case = TRUE)))

##Descriptive check: intervention status by cohort
soc_students %>%
  group_by(Intervention, endYear) %>%
  count()

################################################################################
##PROPENSITY SCORE MATCHING
##- Set formula for available covariates
##- Run matching routine 
##-   Optimal matching preferred to retain treated sample size
##- Assess covariate balance
##- Exact matching on grade and cohort to enforce overlap
################################################################################
##Define formula
ps_formula <- Intervention ~ gender + endYear + grade + ADA + ODR +
  studentrace + studentgender + school_size + pct_FRPL + stu_tch_ratio
##Perform Matching
m.out <- matchit(
  ps_formula,
  data    = soc_students,
  method  = "optimal",
  exact   = ~ endYear + grade,
  distance = "logit",
  ratio   = 1
)

##Covariate balance diagnostics
bal.tab(
  m.out,
  un = TRUE,
  stats = c("m", "s", "v"),
  thresholds = c(m = 0.1, v = 2),
  binary = "std"
)
##Plot balance Statistics
love.plot(
  m.out,
  thresholds = 0.1,
  abs = TRUE,
  var.order = "unadjusted",
  line = TRUE,
  sample.names = c("Original", "Matched"),
  title = "Covariate Balance After Matching"
)

##Extract matched dataset
m.data <- match.data(m.out)




################################################################################
##Descriptive Trajectory: Quarterly Social Studies Grades
##- Provides an overall check on functional form (linearity)
##- Informs growth model specification
################################################################################

m.data %>%
  pivot_longer(
    Q1TermGrade:Q4TermGrade,
    names_to  = "quarter",
    values_to = "Soc_Grade"
  ) %>%
  mutate(
    time0 = match(
      quarter,
      c("Q1TermGrade", "Q2TermGrade", "Q3TermGrade", "Q4TermGrade")
    ) - 1
  ) %>%
  group_by(time0) %>%
  summarise(
    tmean = mean(Soc_Grade, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = time0, y = tmean)) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = 0:3) +
  labs(
    title = "Social Studies Grades Over Time (Matched Sample)",
    x = "Quarter (Time)",
    y = "Mean Social Studies Grade"
  )


################################################################################
##Descriptive Trajectory by Intervention Status
##- Visual comparison of growth patterns prior to model-based estimation
################################################################################

m.data %>%
  pivot_longer(
    Q1TermGrade:Q4TermGrade,
    names_to  = "quarter",
    values_to = "Soc_Grade"
  ) %>%
  mutate(
    time0 = match(
      quarter,
      c("Q1TermGrade", "Q2TermGrade", "Q3TermGrade", "Q4TermGrade")
    ) - 1
  ) %>%
  group_by(Intervention, time0) %>%
  summarise(
    tmean = mean(Soc_Grade, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = time0, y = tmean, color = Intervention, group = Intervention)) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = 0:3) +
  labs(
    title = "Social Studies Grades Over Time by Intervention Status",
    x = "Quarter (Time)",
    y = "Mean Social Studies Grade",
    color = "Intervention"
  )

################################################################################
##Clean and center covariates for interpretability
################################################################################

m.data %<>%
  mutate(
    ADA_gmc       = ADA - mean(ADA, na.rm = TRUE),
    ODR_gmc       = ODR - mean(ODR, na.rm = TRUE),
    sch_size_gmc  = school_size - mean(school_size, na.rm = TRUE),
    STR_gmc       = stu_tch_ratio - mean(stu_tch_ratio, na.rm = TRUE),
    FRPL_gmc      = pct_FRPL - mean(pct_FRPL, na.rm = TRUE),
    Male          = if_else(studentgender == "M", 1, 0),
    Male_Teacher  = if_else(gender == "M", 1, 0),
    AAPI          = if_else(studentrace == "A", 1, 0),
    Hispanic      = if_else(studentrace == "H", 1, 0),
    White         = if_else(studentrace == "W", 1, 0),
    Intervention_Y        = if_else(Intervention == "Y", 1, 0)
  )

################################################################################
##Conditional latent growth curve model
##
##- Linear change across four quarterly observations
##- Intercept reflects Q1 status
##- FIML used to handle missing data under MAR conditional on included covariates
################################################################################

lgcm_model <- '
  i =~ 1*Q1TermGrade + 1*Q2TermGrade + 1*Q3TermGrade + 1*Q4TermGrade
  s =~ 0*Q1TermGrade + 1*Q2TermGrade + 2*Q3TermGrade + 3*Q4TermGrade

  i ~ 1 + Intervention_Y + ADA_gmc + ODR_gmc + sch_size_gmc + STR_gmc +
       Male_Teacher + FRPL_gmc + Male + AAPI + Hispanic + White
       
  s ~ 1 + Intervention_Y + ADA_gmc + ODR_gmc + sch_size_gmc + STR_gmc +
       Male_Teacher + FRPL_gmc + Male + AAPI + Hispanic + White

  i ~~ s
'

##Calculate the Linear Growth Curve Model
fit_lgcm <- growth(
  lgcm_model,
  data = m.data,
  missing = "fiml"
)

##Examine the Results
summary(fit_lgcm, fit.measures = TRUE)


