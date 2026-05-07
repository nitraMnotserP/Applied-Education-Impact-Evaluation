################################################################################
## Project: Educational Intervention Impact Analysis using Multiple Membership Models. 
## Script:  Data Processing, Matching, and Multiple Membership Modeling.
## Purpose: This script is from a real education program evaluation project.
##          It cleans and integrates student-level administrative data and publicly 
##          available school level data, performs propensity score matching to construct 
##          a defensible comparison group, and estimates multiple-membership random effects 
##          models to account for teacher–student clustering when assessing the impact of an intervention
##          on students’ overall GPA. The intervention name has been anonymized as “Intervention”.
## Author:  Preston Martin
## Date:    2026-05-07
################################################################################
##Required Packages:
library(tidyverse) ##Data manipulation & visualization
library(MatchIt) ##Propensity Score Matching 
library(cobalt) ##Assessing covariate balance before and after matching
library(lmerMultiMember) ##Multilevel modeling for multiple membership
library(magrittr) ## %<>%

##Note: Data paths updated to placeholders for submission.

##Read in student/teacher data
cohort_1 <- haven::read_sav('path/to/cohort_1_Year_1_data.sav')
cohort_2 <- haven::read_sav('path/to/cohort_2_Year_1_data.sav')
cohort_3 <- haven::read_sav('path/to/cohort_3_Year_1_data.sav')

##Read in school data from NCES
schools <- read_csv('path/to/NCES_data.csv')

##Align school ID number column names across fields
cohort_1 %<>% 
  rename(school_id = school) %>% 
  select(school_id, staffNumber, studentNumber, Intervention, gender, endYear, grade, Overall_GPA, ADA, ODR, studentrace, studentgender)

cohort_2 %<>% 
  rename(school_id = school) %>% 
  select(school_id, staffNumber, studentNumber, Intervention, gender, endYear, grade, Overall_GPA, ADA, ODR, studentrace, studentgender)

cohort_3 %<>% 
  rename(school_id = school) %>% 
  select(school_id, staffNumber, studentNumber, Intervention, gender, endYear, grade, Overall_GPA, ADA, ODR, studentrace, studentgender)

##rename variables in school file for ease of use.
schools %<>% 
  rename(school_id = School.Name,
         school_size = `School Size (# of students)`,
         Title_1 = `Title I`,
         stu_tch_ratio = `Student Teacher Ratio`,
         pct_FRPL = `%FRPL`) %>% 
  select(school_id, school_size, Title_1,stu_tch_ratio, pct_FRPL)

##Merge in NCES derived data (school data) into student/teacher data
cohort_1 %<>% 
  left_join(schools, by = "school_id") 

cohort_2 %<>% 
  left_join(schools, by = "school_id")

cohort_3 %<>% 
  left_join(schools, by = "school_id")


#################################################################################
##Transform data from LONG to WIDE (students within multiple teachers)
## 
##Original structure:
##- Long format: one row per course grade per student
##- Students appear in multiple rows (one per class with some students having multiple teachers)
##
##Target structure:
##- Wide format: one row per student
##- Multiple columns capturing all teachers associated with each student
##  -one column of comma separated teacher IDs
##- Student-level outcome (Overall_GPA) and covariates retained once per student
#################################################################################

## Stack datasets: Cohorts are mutually exclusive; binding them creates the pool for propensity score matching.
student_wide <- bind_rows(cohort_1, cohort_2, cohort_3) %>% 
  
##Set variable types for subsequent matching.
mutate(
  Intervention = as.factor(Intervention),
  gender = as.factor(gender),
  studentrace = as.factor(studentrace),
  studentgender = as.factor(studentgender), 
  endYear = as.factor(endYear),
  Title_1 = as.factor(Title_1),
  Overall_GPA = as.numeric(Overall_GPA),
  ADA = as.numeric(ADA),
  ODR = as.numeric(ODR),
  school_size = as.numeric(school_size),
  stu_tch_ratio = as.numeric(stu_tch_ratio)
) %>% 
##retain the first occurrence of covariates (all the same data across long format).
summarise(
  ##Retain all unique teachers per student
  teachers = list(unique(staffNumber)), 
  
  ##Student-level covariates (constant within student)
  Overall_GPA = first(Overall_GPA), ##student-level outcome (arithmetic mean for all courses taken)
  school_id = first(school_id),
  staffNumber = first(staffNumber),
  Intervention = first(Intervention),
  gender = first(gender), ##teacher gender
  grade = first(grade),
  studentrace = first(studentrace),
  studentgender = first(studentgender),
  endYear = first(endYear),
  ADA = first(ADA),
  ODR = first(ODR),
  school_size = first(school_size),
  stu_tch_ratio = first(stu_tch_ratio),
  pct_FRPL = first(pct_FRPL),
  Title_1 = first(Title_1),
  
  .by = studentNumber ##keep this to have one subsequent row per student
) %>% 
################################################################################
##Expand teacher membership into wide format
##- Each teacher assigned to a student becomes its own column
##- Unequal numbers of teachers handled via setting as NA
##- This sets up the data for later use in lmermultimember()
################################################################################
mutate(n_teachers = lengths(teachers)) %>% 
  unnest_wider(teachers, names_sep = "_t") %>% 
  unite(col = "Tch.Col",  teachers_t1:teachers_t4, na.rm = TRUE, sep = ",") ##create comma separated column of teacher IDs for matrix later

################################################################################
##Begin Matching Process
##- set formula for available covariates
##- Run matching routine 
##- Assess covariate balance
################################################################################
ps_formula <- Intervention ~ gender + endYear + grade + ADA + ODR + studentrace + studentgender +
  school_size + pct_FRPL + stu_tch_ratio
  
##Match the data
m.out <- matchit(ps_formula, 
                 data = student_wide, 
                 method = "optimal", ##to maximize untreated sample size
                 exact = ~ endYear + grade, ##exact on cohort (endYear) and grade
                 distance = "logit", 
                 ratio = 1) 

##Print the balance table
bal.tab(m.out, 
        un = TRUE,  
        stats = c("m", "s", "v"), 
        thresholds = c(m = 0.1, v = 2), 
        disp.v.ratio = TRUE, 
        binary = "std") 

##Create love plot for balance examination
love.plot(m.out, 
          thresholds = c(m = 0.1), 
          abs = TRUE,   
          var.order = "unadjusted", 
          line = TRUE, 
          sample.names = c("Original", "Matched"), 
          colors = c("#E41A1C", "#377EB8"), 
          title = "Covariate Balance")

##Extract the matched data set
m.data <- match.data(m.out)

################################################################################
##Exploratory Visualizations
################################################################################

##Continuous predictors vs GPA (bivariate linear trends)
m.data %>% 
  ggplot(aes(ADA, Overall_GPA)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

m.data %>% 
  ggplot(aes(ODR, Overall_GPA)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

##Outcome (GPA) differences by intervention status
m.data %>% 
  ggplot(aes(x = Intervention, y = Overall_GPA)) +
  stat_summary(fun = mean, geom = "bar") +
  labs(y = "Mean GPA")

##Teacher-level (multiple membership grouping) variation in GPA relationships
m.data %>% 
  ggplot(aes(ADA, Overall_GPA, colour = factor(Tch.Col))) +
  geom_point() +
  geom_smooth(aes(group = Tch.Col), method = "lm", se = FALSE) +
  labs(colour = "Teacher Combination")


################################################################################
##Data wrangling for multiple-membership models
################################################################################
m.data %<>% 
  mutate(
    ##Verify numeric
    ADA = as.numeric(ADA),
    ODR = as.numeric(ODR),
    pct_FRPL = as.numeric(pct_FRPL),
    school_size = as.numeric(school_size),
    stu_tch_ratio = as.numeric(stu_tch_ratio),
    
    ##Grand Mean Center Continuous Predictors
    ADA_gmc = ADA - mean(ADA, na.rm = TRUE),
    ODR_gmc = ODR - mean(ODR, na.rm = TRUE),
    sch_size_gmc = school_size - mean(school_size, na.rm = TRUE),
    STR_gmc = stu_tch_ratio - mean(stu_tch_ratio, na.rm = TRUE),
    FRPL_gmc = pct_FRPL - mean(pct_FRPL, na.rm = TRUE),
    
    ##Create Standardized scores for continuous variables
    GPA_std = as.numeric(scale(Overall_GPA)),
    ADA_std = as.numeric(scale(ADA)),
    ODR_std = as.numeric(scale(ODR)),
    sch_size_std = as.numeric(scale(school_size)),
    STR_std = as.numeric(scale(stu_tch_ratio)),
    FRPL_std = as.numeric(scale(pct_FRPL)),
    
    ##Convert character factors to dummy indicators (1|0).
    
    ##Student gender
    Male = if_else(studentgender == "M", 1, 0, missing = NA_real_),
    Male_Teacher = if_else(gender == "M", 1, 0 , missing = NA_real_),
    ##Race/ethnicity (choose ONE reference group)
    Black_AA = if_else(studentrace == "B", 1, 0, missing = NA_real_), ##reference (will not be modeled).
    AAPI     = if_else(studentrace == "A", 1, 0, missing = NA_real_),
    Hispanic = if_else(studentrace == "H", 1, 0, missing = NA_real_),
    White = if_else(studentrace == "W", 1, 0, missing = NA_real_),
    ##Intervention
    Intervention.Y = if_else(Intervention == "Y", 1, 0, missing = NA_real_),
    
    ##Title I status
    Title_1 = if_else(Title_1 == "Yes", 1, 0, missing = NA_real_)
  )

################################################################################
##Construct the teacher membership "weights" for multiple membership model
################################################################################
##Construct teacher membership weights from comma-separated teacher IDs
Wa <- weights_from_vector(m.data$Tch.Col, sep = ",")

##Inspect structure of membership matrix
list(Wa)
dimnames(Wa)


################################################################################
##Calculate the Multiple-Membership Models:
##-Random effect for teachers is a list of membership weights (calculated above)
##-Adjusted model includes school-level fixed effects (less than 30 level-3 clusters)
##-Restricted Maximum Likelihood estimation
##-VPC = variance partitioning coefficient 
################################################################################

###Null model to check variance for HLM (MMM) appropriateness. 
mod1 <- lmerMultiMember::lmer(Overall_GPA  ~ 1 + (1 | staffNumber), 
                              data = m.data, 
                              memberships = list(staffNumber = Wa), 
                              REML = TRUE)
summary(mod1)
performance::icc(mod1) ##0.285 for students with one teacher (ICC = VPC when one teacher)

##calculate VPCs for more students with more than one teacher:
##Extract variances manually from output
var_u <- 32.70
var_e <- 82.04

##Function to calculate VPC given k teachers (known max of 4 via column creation above)
calc_vpc <- function(k, sigma2_u, sigma2_e) {
  eff_var_u <- sigma2_u / k ##divide total teacher variance by k-teachers
  vpc <- eff_var_u / (eff_var_u + sigma2_e) ##VPC formula
  return(vpc)
}

##Apply 'calc_vpc' function for 1 to 4 teachers
k_values <- 1:4
vpc_results <- sapply(k_values, calc_vpc, sigma2_u = var_u, sigma2_e = var_e)
###Display results as data frame
data.frame(Teachers = k_values, VPC = vpc_results)
##.      Teachers  VPC
##1        1 0.28499216
##2        2 0.16617542
##3        3 0.11727997
##4        4 0.09061686


##Test the intervention effect:
mod2 <- lmerMultiMember::lmer(Overall_GPA ~ Intervention.Y + (1 | staffNumber), 
                              data = m.data, 
                              memberships = list(staffNumber = Wa), 
                              REML = TRUE)
summary(mod2)

##Adjusted Model with student, teacher, and school level fixed effects:
mod3 <- lmerMultiMember::lmer(Overall_GPA ~ Intervention.Y + ADA_gmc + ODR_gmc + sch_size_gmc + STR_gmc + Male_Teacher +
                                FRPL_gmc + Male + AAPI + Hispanic + White + (1 | staffNumber), 
                              data = m.data, 
                              memberships = list(staffNumber = Wa), 
                              REML = TRUE)
summary(mod3)







