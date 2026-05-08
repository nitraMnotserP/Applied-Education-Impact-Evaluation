################################################################################
## Project: Rater-Adjusted Educational Assessment Analysis
## Script:  Many-Facet Rasch Modeling (Pre/Post)
##
## Purpose:
##   This script is drawn from a real applied education research project.
##   It harmonizes assessment data across rater files, estimates separate
##   Many-Facet Rasch Models (MFRM) for pre- and post-observation waves,
##   and produces rater-adjusted (4 raters) ability estimates for downstream analysis.
##
##   The workflow reflects applied education measurement practices used in
##   program evaluation, with an emphasis on transparency and reproducibility.
##
## Author: Preston Martin
## Date: 2026-05-07
################################################################################

################################################################################
##Required Packages
################################################################################
library(TAM)
library(readxl)
library(tidyverse)
library(magrittr)
library(stringr)
library(WrightMap)

################################################################################
##Read Assessment Data
################################################################################
## Note: Assessment data are not publicly shareable; file paths are illustrative.
rater_A_raw <- read_excel("~/path/name/here/data.xlsx")
rater_B_raw <- read_excel("~/path/name/here/data.xlsx")

################################################################################
##Standardize Column Names Across Files with Helper (clean_names)
################################################################################
clean_names <- function(df) {
  df %>%
    rename_with(str_trim) %>%
    rename_with(~ str_replace_all(.x, ":", "")) %>%
    rename_with(~ str_replace_all(.x, "\\s+", "_"))
}

rater_A_raw <- clean_names(rater_A_raw)
rater_B_raw <- clean_names(rater_B_raw)

################################################################################
##Identify Common Items Across Rater Files
################################################################################
a_cols <- unique(colnames(rater_A_raw))
b_cols <- unique(colnames(rater_B_raw))

a_items <- a_cols[str_detect(a_cols, "^Q[0-9]+_")]
b_items <- b_cols[str_detect(b_cols, "^Q[0-9]+_")]

commonCols <- intersect(a_cols, b_cols)

################################################################################
##Harmonize and Stack Rater Files
################################################################################
rater_A_clean <- rater_A_raw %>%
  select(any_of(commonCols)) %>%
  mutate(
    Rater = factor("A")
  )

rater_B_clean <- rater_B_raw %>%
  select(any_of(commonCols)) %>%
  mutate(
    Rater = factor("B")
  )

assessment_long <- rbind(rater_A_clean, rater_B_clean)

################################################################################
##Split Data into Pre and Post Observation Waves
################################################################################
assessment_pre <- assessment_long %>%
  filter(Observation == 1)

assessment_post <- assessment_long %>%
  filter(Observation == 2)

################################################################################
##Prepare Inputs for Many-Facet Rasch Models
################################################################################

## Pre
pre.facet <- assessment_pre[, 36]
pre.pid   <- assessment_pre[, 2]
pre.resp  <- assessment_pre[, -c(1:6, 36), drop = FALSE]

## Post
post.facet <- assessment_post[, 36]
post.pid   <- assessment_post[, 2]
post.resp  <- assessment_post[, -c(1:6, 36), drop = FALSE]

## Model specification
g.formulaA <- ~ item + step + Rater + item * Rater

################################################################################
##Estimate Many-Facet Rasch Models for Pre and Post Assessments
################################################################################
pre.model <- tam.mml.mfr(
  resp     = pre.resp,
  facets   = pre.facet,
  formulaA = g.formulaA,
  pid      = pre.pid
)

post.model <- tam.mml.mfr(
  resp     = post.resp,
  facets   = post.facet,
  formulaA = g.formulaA,
  pid      = post.pid
)

################################################################################
##Model Diagnostics and Parameter Estimates
################################################################################

##Facet difficulty estimates
pre.difficulty  <- pre.model$xsi.facets
post.difficulty <- post.model$xsi.facets

##Fit statistics
pre.fit  <- tam.fit(pre.model)
post.fit <- tam.fit(post.model)

##Threshold estimates
pre.threshold  <- tam.threshold(pre.model)
post.threshold <- tam.threshold(post.model)

################################################################################
##Diagnostic Plots
################################################################################

##Category characteristic curves
plot(pre.model, type = "items")
plot(post.model, type = "items")

##Item characteristic curves
plot(pre.model, type = "expected")
plot(post.model, type = "expected")

################################################################################
##Person Fit and Ability Estimation
################################################################################
pre.person.fit  <- tam.personfit(pre.model)
post.person.fit <- tam.personfit(post.model)

pre.persons.mod  <- tam.wle(pre.model)
post.persons.mod <- tam.wle(post.model)

pre.theta <- data.frame(
  Rating_Pre    = pre.persons.mod$theta,
  Rating_Pre_SE = pre.persons.mod$error
)

post.theta <- data.frame(
  Rating_Post    = post.persons.mod$theta,
  Rating_Post_SE = post.persons.mod$error
)

thetas <- data.frame(cbind(pre.theta, post.theta))

################################################################################
##Wright Maps
################################################################################
thresh_pre <- t(pre.threshold)
wrightMap(pre.persons.mod$theta, thresh_pre)

thresh_post <- t(post.threshold)
wrightMap(post.persons.mod$theta, thresh_post)

################################################################################
##Create Analytic Dataset and Calculate Change Scores
################################################################################
analytic_data <- assessment_long %>%
  filter(Observation == 1 & Rater == "A") %>%
  cbind(thetas) %>%
  mutate(Chg_Score = Rating_Post - Rating_Pre)

################################################################################
##Descriptive Summaries
################################################################################
analytic_data %>%
  group_by(Program) %>%
  count()

analytic_data %>%
  group_by(Program) %>%
  summarise(
    meanRating_Pre     = mean(Rating_Pre),
    varRating_Pre      = var(Rating_Pre),
    meanRating_Post    = mean(Rating_Post),
    varRating_Post     = var(Rating_Post),
    meanRating_Change  = mean(Chg_Score),
    varRating_Change   = var(Chg_Score)
  )

################################################################################
##Regression Analysis
################################################################################
mod.1 <- lm(Chg_Score ~ factor(Program), analytic_data)
summary(mod.1)
