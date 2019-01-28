library(tidyverse)
library(plotly)
library(countrycode)

#dataread
data <- read.csv("data/winemag-data-130k-v2.csv", stringsAsFactors = FALSE)

#filtering out specific values and columns
data <- data %>% 
  select(-X, -region_2, -taster_twitter_handle) %>% #unneeded fields
  filter(country != "",
         variety != "",
         price != "")%>% #removing NAs
  mutate(country = if_else(country =="England", "United Kingdom", as.character(country)),
         countrycodes = countrycode(country, 'country.name', 'iso3c'),
         region_1 = if_else(region_1 != "", region_1, "N/A"),
         priceCategory = ifelse(price <= 10, "($0 - $10) Value",
                         ifelse(price > 10 & price <=30, "($11 - $30) Popular", 
                         ifelse(price > 30 & price <= 100, "($30 - $100) Premium",
                         ifelse(price > 100 & price <= 300, "($100 - $300) Ultra Premium", 
                                "($300+ Luxury)")
                         ))))


# creating a new verage dataframe for plotly map
avg_data <- data %>% group_by(country, countrycodes) %>% 
            summarise(avg_rating = mean(points))

#reading the `coutnrycodes` lookup table
countrydata <- read_csv('data/countrynames.csv')
countrydata$country <- as.factor(countrydata$country)
countrydata$countrycodes <- as.factor(countrydata$countrycodes)


#joining lookup table with average ratings for plotly map
full_data <- countrydata %>%
              left_join(avg_data, by="countrycodes") %>% 
              select(country.x, countrycodes, avg_rating)

full_data <- full_data %>% 
  filter(country.x != "Antarctica") %>% 
  mutate(avg_rating = if_else(is.na(avg_rating), 80 ,avg_rating))

full_data$my_text = if_else(full_data$avg_rating == 80, "",
  paste("Avg. Wine Rating: " , as.character(round(full_data$avg_rating,2)), 
                          "<BR>Country: ", as.character(full_data$country.x), sep=""))



# Adding hover text formatting of wine titles with a line breaks
data$title_wrapped <- paste(str_match(data$title, ".*(?=\\s\\()"),
                            "<BR>",
                            str_match(data$title, "\\(.*"),
                            sep = "")


# creating column for wine vintage
data$vintage <- as.integer(
  str_extract(data$title, "(?<=\\s)(19[^012]\\d|20\\d{2})(?=\\s)"))


#saving fields as sorted character lists to have unique objects in dropdown filters
country <- as.character(unique(data$country))
country <- sort(country)
region <- as.character(unique(data$region_1))
variety <- as.character(unique(data$variety))
variety <- sort(variety)
priceCategory <- as.character(unique(data$priceCategory))
vintage <- sort(as.character(unique(data$vintage)))
