library(stringr)
library(dplyr)
# filter out jobs titles without "data"
glassdoor = read.csv("/Users/rjn/OneDrive/Williams/fall_2022/stat_458/stat458_project/glassdoor_jobs.csv")
glassdoor = glassdoor[grep("(?i)data",glassdoor$Job.Title),]
glassdoor = glassdoor %>% select(-Competitors)
for(i in 1:ncol(glassdoor))
  glassdoor[,i] = ifelse(glassdoor[,i] == -1, NA, glassdoor[,i])

# seniority category
glassdoor$Seniority = grepl("(?i)senior|sr|manager|director|vp|lead|principal|i{2,}", glassdoor$Job.Title)

# hq and job location by state
glassdoor$Location.State = gsub(pattern = ".+, ",x = glassdoor$Location,replacement = "")
glassdoor$HQ.State = gsub(pattern = ".+, ",x = glassdoor$Headquarters,replacement = "")

# clean up some mess in location
glassdoor$Location.State = ifelse(glassdoor$Location.State %in% state.name & !is.na(glassdoor$Location.State), 
                                  state.abb[match(glassdoor$Location.State, state.name)],
                                  glassdoor$Location.State)
glassdoor$HQ.State = ifelse(glassdoor$HQ.State %in% state.abb | is.na(glassdoor$HQ.State), 
                            glassdoor$HQ.State,
                            "International")

# convert salary to numeric
salaryList = strsplit(glassdoor$Salary.Estimate, "-")
salaryDF = as.data.frame(t(sapply(salaryList, str_extract, "[0-9]+")))
names(salaryDF) = c("Salary.lwr", "Salary.upr")
salaryDF = apply(salaryDF,c(1,2),as.numeric)

# calculate average
glassdoor$meanSalary = apply(salaryDF, 1, mean)
glassdoor$rangeSalary = apply(salaryDF, 1, function(x) max(x) - min(x))


# annualize hourly wage, assuming 2080 working hours per year
#glassdoor$meanSalary = ifelse(grepl("(?i)hour", glassdoor$Salary.Estimate), 2.080*glassdoor$meanSalary, glassdoor$meanSalary)

# remove hourly wage
glassdoor = glassdoor[!grepl("(?i)hour", glassdoor$Salary.Estimate),]

# categoriuze type of ownership
temp = str_extract(glassdoor$Type.of.ownership, "(?i)private|public")  
temp[is.na(temp)] = "other"
temp[is.na(glassdoor$Type.of.ownership)] = NA
glassdoor$transformed.ownership = temp

# categorize year founded
glassdoor$Founded.cat = cut(glassdoor$Founded, breaks = c(0,1978,1999,2010,2019))
