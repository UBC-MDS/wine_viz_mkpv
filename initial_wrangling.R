library(tidyverse)
library(countrycode)
library(plotly)

data <- read.csv("data/winemag-data-130k-v2.csv", stringsAsFactors = FALSE)

data$country <- as.factor(data$country)

data <- data %>% 
  select(-X, -region_2, -taster_twitter_handle) %>% 
  filter(country != "") %>% 
  mutate(country = if_else(country =="England", "United Kingdom", as.character(country)),
         countrycodes = countrycode(country, 'country.name', 'iso3c'))

country <- as.character(unique(data$country))

avg_data <- data %>% group_by(country, countrycodes) %>% summarise(avg_rating = mean(points))

countrydata <- read_csv('data/countrynames.csv')
countrydata$country <- as.factor(countrydata$country)
countrydata$countrycodes <- as.factor(countrydata$countrycodes)

full_data <- countrydata %>% left_join(avg_data, by="countrycodes") %>% select(country.x, countrycodes, avg_rating)

full_data <- full_data %>% 
  filter(country.x != "Antarctica") %>% 
  mutate(avg_rating = if_else(is.na(avg_rating), 80 ,avg_rating))

full_data$my_text = paste("The average rating is: " , if_else(full_data$avg_rating == 80, "No data", as.character(round(full_data$avg_rating,2))), 
                          "<BR>Country: ", as.character(full_data$country.x), sep="")