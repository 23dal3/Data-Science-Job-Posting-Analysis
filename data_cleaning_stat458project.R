library(stringr)
glassdoor = read.csv("/Users/rjn/OneDrive/Williams/fall_2022/stat_458/stat458_project/glassdoor_jobs.csv")
glassdoor = glassdoor[grep("(?i)data",glassdoor$Job.Title),]
glassdoor$Seniority = grepl("(?i)senior|sr|manager|director|vp|lead|principal|i{2,}", glassdoor$Job.Title)
glassdoor$Location.State = gsub(pattern = ".+, ",x = glassdoor$Location,replacement = "")
glassdoor$HQ.State = gsub(pattern = ".+, ",x = glassdoor$Headquarters,replacement = "")
#glassdoor$job.modifier = str_replace(glassdoor$Job.Title, "(?i) ?Data [a-z]+[, -]*[a-z]*","")