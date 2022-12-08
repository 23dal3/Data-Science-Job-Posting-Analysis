library(pander)
library(ggplot2)
library(GGally)
library(gridExtra)
library(datasets)
library(knitr)
library(dplyr)
library(cowplot)
library(grid)
library(gridExtra)
library(nnet)
library(lmtest)
library(readr)
library(tidyverse)

set.seed(123)

glassdoor <- read.csv("/Users/rjn/OneDrive/Williams/fall_2022/stat_458/stat458_project/cleaned_glassdoor.csv")
glassdoor <- na.omit(glassdoor[, c("Rating", "Seniority", "meanSalary", "transformed.ownership", "Founded.cat", "Revenue", "Size", "Sector", "rangeSalary", "Location.State", "HQ.State", "Founded")])

# recategorizing Sector variable
orig = sort(unique(glassdoor$Sector))
new = c("Finance", 
        "Heavy Industry", 
        "Heavy Industry", 
        "Education and Culture",
        "Healthcare", 
        "Heavy Industry", 
        "Business Services", 
        "Retail", 
        "Education and Culture",
        "Finance",
        "Other",
        "Healthcare",
        "Information Technology",
        "Finance",
        "Heavy Industry",
        "Education and Culture",
        "Heavy Industry",
        "Other",
        "Heavy Industry",
        "Heavy Industry",
        "Retail",
        "Information Technology",
        "Heavy Industry")

glassdoor$Sector.new = new[match(glassdoor$Sector, orig)]

mod <- multinom(transformed.ownership~ Rating + Seniority + meanSalary + Revenue+ Size + Sector + rangeSalary+ Location.State + HQ.State + Founded, data= na.omit(glassdoor))
summary(mod)
z <- summary(mod)$coefficients/summary(mod)$standard.errors
# 2-tailed Wald z tests to test significance of coefficients
p <- (1 - pnorm(abs(z), 0, 1)) * 2
p
# using BIC criterion
step(mod, direction = "both", k =log(length(glassdoor)))
# using AIC criterion
step(mod, direction = "both")
# Both converge to transformed.ownership ~ Founded.cat + Revenue + Size + Sector
optimized_mod = multinom(transformed.ownership ~ Founded.cat + Revenue + Size + Sector, data = glassdoor)
summary(optimized_mod)
x$z <- summary(optimized_mod)$coefficients/summary(optimized_mod)$standard.errors
# 2-tailed Wald z tests to test significance of coefficients
p <- (1 - pnorm(abs(z), 0, 1)) * 2
p

coefficents = data.frame(summary(optimized_mod)$coefficients)
coefficients2 <- mutate_all(coefficents, function(x) as.numeric(as.character(x)))
logit2prob <- function(logit){
  odds <- exp(logit)
  prob <- odds / (1 + odds)
  return(prob)
}
coeff_probs= data.frame(lapply(coefficients2 ,logit2prob))
