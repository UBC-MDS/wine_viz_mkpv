library(shiny)
library(tidyverse)
library(countrycode)
library(ggplot2)
<<<<<<< HEAD
library(shinyWidgets)
=======
library(plotly)
library(viridisLite)

# run the data wrangling script
source("initial_wrangling.R")
>>>>>>> upstream/master

ui <- fluidPage(
    titlePanel("Wine Rating App", 
               windowTitle = "Wine app"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("WineRating", "Select your desired rating range.",
                        min = 80, max = 100, value = c(80,100)),
            
            sliderInput("WinePrice", "Select your desired price range.",
                        min = 0, max = 10000, value = c(0,10000)),
            
            pickerInput("WineCountry", 
                        label = "Choose a Country",
                        choices = country,
                        options = list(`actions-box` = TRUE),
                        multiple = TRUE,
                        selected = "All"),
            
            uiOutput('WineRegion'),
        
            pickerInput("WineVariety",
                        label = "Choose a Wine Variety",
                        choices = variety,
                        options = list(`actions-box` = TRUE),
                        multiple = TRUE,
                        selected = "")),
                
        mainPanel(plotlyOutput("map"),
                  fluidRow(
                      column(6,
                             plotlyOutput("variety")),
                      column(6,
                             plotlyOutput("price_rate"))))
        )

    )

server <- function(session, input, output) {
    
    output$WineCountry <- renderUI({
        selectInput('WineCountry', 'Country', sort(unique(data$country)))
    })
    
    output$WineRegion <- renderUI({
        if (is.null(input$WineCountry) || input$WineCountry == ""){return()}
        else selectInput('WineRegion', "Region", 
                         c(data$region_1[which(data$country == input$WineCountry)]))
    })
    
    data_filter <- reactive({
        data %>% 
            filter(points > input$WineRating[1],
                   points < input$WineRating[2],
<<<<<<< HEAD
                   country == output$WineCountry,
                   variety == input$WineVariety))
=======
                   country == input$WineCountry)
        })
    
>>>>>>> upstream/master
    
    output$map <- renderPlotly(
        plot_geo(full_data) %>%
            add_trace(
                z = ~avg_rating,
                color = ~avg_rating, 
                colors = 'RdPu',
                text = full_data$my_text, 
                locations = ~countrycodes, 
                marker = list(line = list(color = toRGB("grey"), width = 0.5))
            ) %>%
            layout(
                title = 'Average Wine Ratings by Country',
                geo = list(showframe = FALSE,
                           showcoastlines = FALSE,
                           projection = list(type = 'Mercator'))
            ) %>% hide_colorbar())
    
    output$variety <- renderPlotly(
            data_filter() %>% 
                select(variety, points) %>% 
                group_by(variety) %>% 
                summarise(avg_points = mean(points)) %>% 
                filter(variety != "") %>% 
                top_n(10) %>% 
                arrange(desc(avg_points)) %>% 
                plot_ly(x = ~avg_points, 
                        y = ~variety, 
                        type = 'bar',
                        orientation = 'h') %>% 
<<<<<<< HEAD
                layout(xaxis = list(range = c(80, 100), title = ""), 
                       yaxis = list(title = ""), font = list(size = 10)))
            
    
    output$test <- renderPlotly(
            data_filter() %>% 
                plot_ly(x = ~points,
                        type = "histogram",
                        histnorm = "probability"))


=======
                layout(xaxis = list(range = c(80, 100)), showlegend=FALSE ))

    output$price_rate <- renderPlotly({
        
        # build plot with ggplot syntax
        p <- data_filter() %>%
                ggplot(aes(x = points,
                           y = price,
                           colour = 'blue',
                           text = paste(title_wrapped, 
                                        "  |  $",  price,
                                        " Points:", points, 
                                        " Var:", variety,
                                        sep = ""))) +
                geom_jitter(alpha = .5, color = 'cyan4', width = .15) +
                theme_bw() +
                theme(legend.position="none")
        
        ggplotly(p, tooltip = "text") # tooltip argument to suppress the default information and just show the custom text
    })
    
>>>>>>> upstream/master
}


shinyApp(ui = ui, server = server)
