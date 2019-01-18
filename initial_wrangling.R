library(tidyverse)
library(plotly)
library(countrycode)

#dataread
data <- read.csv("data/winemag-data-130k-v2.csv", stringsAsFactors = FALSE)

#setting as factor
data$country <- as.factor(data$country)

#filtering out specific values and columns
data <- data %>% 
  select(-X, -region_2, -taster_twitter_handle) %>% 
  filter(country != "",
         variety != "")%>% 
  mutate(country = if_else(country =="England", "United Kingdom", as.character(country)),
         countrycodes = countrycode(country, 'country.name', 'iso3c'))

#filter values
country <- as.character(unique(data$country))
country <- sort(country)
region <- as.character(unique(data$region_1))
variety <- as.character(unique(data$variety))
variety <- sort(variety)



##### for map
avg_data <- data %>% group_by(country, countrycodes) %>% 
            summarise(avg_rating = mean(points))

#reading lookup table
countrydata <- read_csv('data/countrynames.csv')
countrydata$country <- as.factor(countrydata$country)
countrydata$countrycodes <- as.factor(countrydata$countrycodes)


#joining lookup table with average ratings
full_data <- countrydata %>%
              left_join(avg_data, by="countrycodes") %>% 
              select(country.x, countrycodes, avg_rating)

full_data <- full_data %>% 
  filter(country.x != "Antarctica") %>% 
  mutate(avg_rating = if_else(is.na(avg_rating), 80 ,avg_rating))

full_data$my_text = paste("The average rating is: " , 
                          if_else(full_data$avg_rating == 80, "No data", 
                                  as.character(round(full_data$avg_rating,2))), 
                          "<BR>Country: ", as.character(full_data$country.x), sep="")




# Add version of title with a line break for tooltip display
data$title_wrapped <- paste(str_match(data$title, ".*(?=\\s\\()"),

                            "<BR>",
                            str_match(data$title, "\\(.*"),
                            sep = "")

# Add column for vintage
data$vintage <- as.integer(
  str_extract(data$title, "(?<=\\s)(19[^012]\\d|20\\d{2})(?=\\s)"))


vintage <- sort(as.character(unique(data$vintage)))
