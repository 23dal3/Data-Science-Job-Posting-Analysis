# Data-Science-Job-Posting-Analysis
### by Daniel Lee and Jianing Ren
Multinomial analysis of web-scraped Glassdoor data science job postings

# Table of contents
1. [Introduction and Project Proposal](#Introduction)
2. [*R* Analysis](#Analysis)
3. [Files](#Files)

## Introduction and Project Proposal <a name="Introduction"></a>
As statistics majors fresh out of college, finding a suitable job from a reputable company is one of our top concerns. However, what characteristics make a company the way it is? In this project, we are proposing using a multinomial model to predict ownership type of a firm based on positions with “data” in the title. Company ownership falls into three main categories: privately-owned, publicly-traded, or other (such as nonprofit and governmental organizations). The data was scraped from Glassdoor, the biggest job review and posting site, by Kaggle user Rekib Ahmed. The web-scraped profile for every job posting gives us the title, salary estimate (with some listing in annual salary and some hourly), job description, rating (a 1-5 score that former or current employees give the company), company name, location (city and state), size (number of employees in range format), location of the corporate headquarters, and when the company was founded. 
The dataset contains 887 jobs with 56% of the employers being privately owned, 28% being publicly traded, and 16% of companies falling in the other category, which is a rather suitable proportion for multinomial classification. The job titles are mainly concerned with data science, with 51% being the exact string “Data Science”. This does not account for the other titles that are an amalgamation of other modifiers combined with data science: i.e. “Principal Data Scientist”, “Junior Data Scientist”, or “Associate Data Scientist”. Because these modifiers imply different seniority thus can potentially correlate with the salary estimate variable, we will attempt to extract them using text processing tools (such as Regular Expression) as an additional predictor. The majority of the ratings are concentrated from 3-5, with some null values denoted by -1 in this data set. These will have to be cleaned. The size of the companies are predominantly 51 to 200 employees (20%), with companies of size 1000-5000 employees coming in at a close second (16%). The salary estimates are in different units (annual vs. hourly), therefore they need to be standardized. 
Using this model, we attempt to study if any of these company characteristics can effectively distinguish between public, private, and other (government, NPO) ownerships. For example, do private companies tend to pay more after controlling for “seniority” of the job applicant? Do public companies have lower ratings? Does California attract more public companies that employ data science specialists, or does Washington DC attract more government/NPOs? As an extension, we can even try to predict the rating of a company through an ordinal multinomial model using its ownership category and the rest of the variables. All of these are important and relevant questions for students in a senior statistics seminar looking for jobs in the age of “Big Data”, and can provide insight into the broader job market.

## *R* Analysis <a name="Analysis"></a>
Explanation Goes Here

## Files <a name="Files"></a>
* `glassdoor_jobs.csv` 
  *  A csv file from [kaggle](https://www.kaggle.com/datasets/rkb0023/glassdoor-data-science-jobs) that is web-scraped Data Science jobs containing columns     of salary estimates, job location, company size, title, ownership type, and more.
