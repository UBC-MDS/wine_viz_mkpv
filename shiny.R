library(shiny)
library(tidyverse)
library(countrycode)
library(ggplot2)


ui <- fluidPage(
    titlePanel("Wine Rating App", 
               windowTitle = "Wine app"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("WineRating", "Select your desired rating range.",
                        min = 80, max = 100, value = c(80,100)),
            selectInput("WineCountry", 
                        label = "Choose a Country",
                        choices = country,
                        multiple = TRUE,
                        selected = TRUE)),
        mainPanel(
                  plotlyOutput("map"),
                  verbatimTextOutput("event"),
                  plotlyOutput("price_hist")
                  )
    )
)


server <- function(input, output) {
    
    
    
    data_filter <- reactive(
        data %>% 
            filter(points > input$WineRating[1],
                   points < input$WineRating[2],
                   country == input$WineCountry)
    )
    
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
            ) %>% hide_colorbar()
        )
    
    
    
    output$price_hist <- renderPlotly(
        data_filter() %>% 
            plot_ly(x = ~points,
                   type = "histogram",
                   histnorm = "probability"))
    


}


shinyApp(ui = ui, server = server)
