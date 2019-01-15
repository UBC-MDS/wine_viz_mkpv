library(shiny)
library(tidyverse)
library(countrycode)
library(ggplot2)
library(plotly)


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
                        selected = 'Canada')),
        mainPanel(plotlyOutput("map"),
                  fluidRow(
                      column(6,
                             plotlyOutput("variety")),
                      column(6,
                             plotlyOutput("price_rate"))))
        )

    )

server <- function(input, output) {
    
    
    
    data_filter <- reactive({
        data %>% 
            filter(points > input$WineRating[1],
                   points < input$WineRating[2],
                   country == input$WineCountry)
        })
    
    
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
                layout(xaxis = list(range = c(80, 100))))

    output$price_rate <- renderPlotly({
        
        # build plot with ggplot syntax
        p <- data_filter() %>%
                ggplot(aes(x = points,
                           y = price,
                           colour = variety,
                           text = paste(title, "<br>Rating:", points, "      Price:", price))) +
                geom_point(alpha = (1/3)) +
                theme(legend.position="none")
        
        ggplotly(p, tooltip = "text") # tooltip argument to suppress the default information and just show the custom text
    })
    
}


shinyApp(ui = ui, server = server)
