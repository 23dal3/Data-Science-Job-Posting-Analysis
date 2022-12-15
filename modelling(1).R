library(pander)
library(ggplot2)
library(GGally)
library(gridExtra)
library(datasets)
library(kableExtra)
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

glassdoor <- read.csv("cleaned_glassdoor.csv")
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
x=summary(optimized_mod)
z <- summary(optimized_mod)$coefficients/summary(optimized_mod)$standard.errors
z
# 2-tailed Wald z tests to test significance of coefficients
p <- (1 - pnorm(abs(z), 0, 1)) * 2
p

coefficents = data.frame(summary(optimized_mod)$coefficients)
coefficients2 <- mutate_all(coefficents, function(x) as.numeric(as.character(x)))
# logit2prob <- function(logit){
#   odds <- exp(logit)
#   prob <- odds / (1 + odds)
#   return(prob)
# }
coeff_odds= data.frame(lapply(coefficients2 ,exp))

Private = as.numeric(as.vector(coefficents[1,]))
Public = as.numeric(as.vector(coefficents[2,]))
names = c("X Intercept", "Founded Between: 1983-2003","Founded Between: 2013 - 2023","Founded Between: 2003 - 2013","Revenue: 10 to 50 billion (INR)","Revenue: 10 to 50 million (INR)","Revenue: 100 to 500 billion (INR)","Revenue: 100 to 500 million (INR)","Revenue: 5 to 10 billion (INR)","Revenue: 50 to 100 billion (INR)","Revenue: 50 to 100 million (INR)","Revenue: 500 million to 1 billion (INR)","Revenue: 500+  billion (INR)","Revenue: Unknown","Size: 10000+ employees","Size: 1001 to 5000 employees","Size: 201 to 500 employees","Size: 5001 to 10000 employees","Size: 501 to 1000 employees","Size: 51 to 200 employees"," Size: Unknown","Sector: Education and Culture","Sector: Finance","Sector: Healthcare","Sector: Heavy Industry","Sector: Information Technology","Sector: Other","Sector: Retail")
table<- data.frame(names, Private, Public)
x = c("X Intercept", "Founded Between: 1983-2003","Founded Between: 2003 - 2013", "Founded Between: 2013 - 2023","Revenue: 10 to 50 million (INR)","Revenue: 50 to 100 million (INR)", "Revenue: 100 to 500 million (INR)", "Revenue: 500 million to 1 billion (INR)","Revenue: 5 to 10 billion (INR)", "Revenue: 10 to 50 billion (INR)","Revenue: 50 to 100 billion (INR)","Revenue: 100 to 500 billion (INR)","Revenue: 500+  billion (INR)","Revenue: Unknown","Size: 51 to 200 employees", "Size: 201 to 500 employees","Size: 501 to 1000 employees","Size: 1001 to 5000 employees","Size: 5001 to 10000 employees","Size: 10000+ employees", " Size: Unknown","Sector: Education and Culture","Sector: Finance","Sector: Healthcare","Sector: Heavy Industry","Sector: Information Technology", "Sector: Retail", "Sector: Other")
glassdoor <- na.omit(glassdoor[, c("transformed.ownership", "Founded.cat", "Revenue", "Size", "Sector")])
glassdoor %>% group_by(transformed.ownership) %>% summarize(count = n())
table = table %>% arrange(sapply(names, function(y) which(y == x)))
table %>%
  kbl(caption = "Coefficients in Log(Odds)") %>%
  kable_classic(full_width = F, html_font = "Cambria")
names(coefficients2)
# Transpose everything other than the first column
coefficients.T <- as.data.frame(as.matrix(coefficients))
# Assign first column as the column names of the transposed dataframe
colnames(coefficients.T) <- names
rev_mod = multinom(transformed.ownership ~ Revenue, data = glassdoor)
pis <-predict(rev_mod, data.frame(Revenue = c("Unknown / Non-Applicable","100 to 500 billion (INR)","500+ billion (INR)","100 to 500 million (INR)","10 to 50 billion (INR)",  "10 to 50 million (INR)", "50 to 100 billion (INR)", "5 to 10 billion (INR)", "1 to 5 billion (INR)", "500 million to 1 billion (INR)", "50 to 100 million (INR)")), type = "probs"); pis
pis <- data.frame(c("Unknown / Non-Applicable","100 to 500 billion (INR)","500+ billion (INR)","100 to 500 million (INR)","10 to 50 billion (INR)",  "10 to 50 million (INR)", "50 to 100 billion (INR)", "5 to 10 billion (INR)", "1 to 5 billion (INR)", "500 million to 1 billion (INR)", "50 to 100 million (INR)"), pis)
colnames(pis)[1] ="Revenue"
z= c("Unknown / Non-Applicable", "10 to 50 million (INR)","50 to 100 million (INR)", "100 to 500 million (INR)", "500 million to 1 billion (INR)","1 to 5 billion (INR)","5 to 10 billion (INR)", "10 to 50 billion (INR)","50 to 100 billion (INR)","100 to 500 billion (INR)","500+ billion (INR)")
pis = pis %>% arrange(sapply(Revenue, function(y) which(y == z)))
pis$Revenue = c("10 to 50 million","50 to 100 million", "100 to 500 million", "500 million to 1 billion","1 to 5 billion","5 to 10 billion", "10 to 50 billion","50 to 100 billion","100 to 500 billion","500+ billion","Unknown / Non-Applicable")
colors <- c("Public" = "aquamarine3", "other" = "aquamarine4", "Private" = "chartreuse4")
pis$Revenue  <- factor(pis$Revenue,levels = c("Unknown / Non-Applicable", "10 to 50 million","50 to 100 million", "100 to 500 million", "500 million to 1 billion","1 to 5 billion","5 to 10 billion", "10 to 50 billion","50 to 100 billion","100 to 500 billion","500+ billion"))
ggplot(data=pis, aes(x=as.factor(Revenue), y=Public)) +
  geom_line(aes(col = "Public")) +
  geom_line(aes( x=as.factor(Revenue), y = other, col = "other"))+
  geom_line(aes(x=as.factor(Revenue), y = Private, col = "Private")) + ggtitle("Probability of a Company Being Public Based on Revenue") + ylab("Probability of being Public") + xlab("Revenue (INR)")
ggplot(data=pis, aes(x=Revenue, y=other)) +
  geom_line(col = "blue") +
  geom_line(aes(x=Revenue, y = Public), col = "purple")+
  geom_line(aes(x=Revenue, y = Private), col = "red")








pis$Revenue = factor(pis$Revenue, levels = unique(pis$Revenue))

pis %>% gather(-Revenue, key = "Ownership", value = "Predicted Prob") %>% 
  ggplot(aes(x = Revenue, y = `Predicted Prob`, group = Ownership, col = Ownership)) + geom_smooth(se= FALSE)+ geom_point()+
  scale_color_brewer(palette = "Paired") + 
  theme_bw()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))









size_mod = multinom(transformed.ownership ~ Size, data = glassdoor)
pis <-predict(size_mod, data.frame(Size = c("Unknown", "1 to 50 employees", "51 to 200 employees", "201 to 500 employees", "501 to 1000 employees", "1001 to 5000 employees","5001 to 10000 employees","10000+ employees")), type = "probs"); pis
pis <- data.frame(c("Unknown", "1 to 50 employees", "51 to 200 employees", "201 to 500 employees", "501 to 1000 employees", "1001 to 5000 employees","5001 to 10000 employees","10000+ employees"), pis)
colnames(pis)[1] ="Size"
pis$Size  <- factor(pis$Size,levels = c("Unknown", "1 to 50 employees", "51 to 200 employees", "201 to 500 employees", "501 to 1000 employees", "1001 to 5000 employees","5001 to 10000 employees","10000+ employees"))
pis %>% gather(-Size, key = "Ownership", value = "Predicted Prob") %>% 
  ggplot(aes(x = Size, y = `Predicted Prob`, group = Ownership, col = Ownership)) + geom_smooth(se= FALSE)+ geom_point()+
  scale_color_brewer(palette = "Paired") + 
  theme_bw()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

founded_mod = multinom(transformed.ownership ~ Founded.cat, data = glassdoor)
pis <-predict(founded_mod, data.frame(Founded.cat = c( "(0,1.98e+03]","(1.98e+03,2e+03]","(2e+03,2.01e+03]","(2.01e+03,2.02e+03]")), type = "probs"); pis
pis <- data.frame(c( "(0,1.98e+03]","(1.98e+03,2e+03]","(2e+03,2.01e+03]","(2.01e+03,2.02e+03]"), pis)
pis$Founded  <- c( "0-1983","1983-2003","2003-2013","2013-2023")
colnames(pis)[1] ="Founded"
pis$Founded  <- factor(pis$Founded,levels = c( "0-1983","1983-2003","2003-2013","2013-2023"))
pis %>% gather(-Founded, key = "Ownership", value = "Predicted Prob") %>% 
  ggplot(aes(x = Founded, y = `Predicted Prob`, col = Ownership)) + geom_bar()+ 
  scale_color_brewer(palette = "Paired") + 
  theme_bw()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
