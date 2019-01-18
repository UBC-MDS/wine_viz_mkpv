library(shiny)
library(tidyverse)
library(countrycode)
library(ggplot2)
library(shinyWidgets)
library(plotly)
library(viridisLite)

# run the data wrangling script
source("initial_wrangling.R")

ui <- fluidPage(
    #tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: purple}")),
    #tags$style(HTML(".js-irs-1 .irs-single, .js-irs-1 .irs-bar-edge, .js-irs-1 .irs-bar {background: purple}")),
    

    tags$style(type = "text/css", "
      .irs-bar {width: 100%; height: 10px; background: purple; border-top: 1px solid purple; border-bottom: 1px solid purple;}
      .irs-bar-edge {background: purple; border: 1px solid purple; height: 15px; border-radius: 0px; width: 20px;}
    "),
    
    titlePanel("Wine Rating App", 
               windowTitle = "Wine app"),
    sidebarLayout(
        sidebarPanel(
            
            setSliderColor(c("#96027A", "#96027A"), c(1, 2)),
            
            sliderInput("WineRating", "Select your desired rating range.",
                        min = 80, max = 100, value = c(80,100)),
            
            sliderInput("WinePrice", "Select your desired price range.",
                        min = 0, max = 10000, value = c(0,10000)),
            
            pickerInput("WineCountry", 
                        label = "Choose a Country",
                        choices = country,
                        multiple = TRUE,
                        options = list(`actions-box` = TRUE),
                        selected = country),
            
            uiOutput('WineRegion'),
            
            
            pickerInput("WineVintage", 
                        label = "Choose a Vintage Year",
                        choices = vintage,
                        multiple = TRUE,
                        options = list(`actions-box` = TRUE),
                        selected = vintage)),
            
                
        mainPanel(plotlyOutput("map"),
                  fluidRow(
                      column(6,
                             plotlyOutput("variety")),
                      column(6,
                             plotlyOutput("price_rate"))))
        )

    )

server <- function(input, output, session) {
    
    output$WineRegion <- renderUI({
        if (is.null(input$WineCountry) || input$WineCountry == ""){return()}
        else pickerInput('WineRegion', "Region", 
                         choices = c(unique(sort(data$region_1[which(data$country == input$WineCountry)]))),
                         options = list(`actions-box` = TRUE),
                         multiple = TRUE)
    })
    
    #output$WineVariety <- renderUI({
    #    pickerInput('WineVariety', "Variety", 
    #                     choices = c(unique(sort(data$variety[which(data$country == input$WineCountry)]))),
    #                     multiple = TRUE, 
    #                     options = list(`actions-box` = TRUE),
    #                     selected = variety)
    #})
    
    data_filter <- reactive({
        data %>% 
            filter(points > input$WineRating[1],
                   points < input$WineRating[2],
                   price > input$WinePrice[1],
                   price < input$WinePrice[2],
                   country == input$WineCountry)
        })
    
    
    
    output$map <- renderPlotly(
        full_data %>% #filter(country.x == input$WineCountry) %>% 
        plot_geo() %>%
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
                #arrange(desc(avg_points)) %>% 
                plot_ly(x = ~avg_points, 
                        y = ~variety,
                        color = ~avg_points, 
                        type = 'bar',
                        colors = 'RdPu',
                        orientation = 'h',
                        text = ~round(avg_points,0),
                        textposition = 'outside') %>% 
                layout(xaxis = list(range = c(80, 100), title = "Average Rating"), 
                       yaxis = list(title = "Variety", tickangle = 45), font = list(size = 10),
                       title = "Top 10 Varieties with Ratings"
                       ) 
            %>% hide_colorbar()) 



     output$price_rate <- renderPlotly({
         
         # build plot with ggplot syntax
         p <- data_filter() %>%
                 ggplot(aes(x = points,
                            y = price,
                            color = "#96027A",
                            text = paste("Title: ", title_wrapped, 
                                         "<br>", "Price: $",  price,
                                         "<BR> ", "Rating: ", points, 
                                        "<BR>", "Variety: ", variety,
                                         sep = ""))) +
                 geom_jitter(alpha = .5, color = "#96027A", width = .15) +
                 theme_bw() +
                 labs(title = "Price vs. Ratings", x = "Rating", y = "Price" ) +
                 theme(legend.position="none",
                       panel.border = element_blank(),
                       panel.grid.major = element_blank(),
                       panel.grid.minor = element_blank(),
                       axis.line = element_line(colour = "#E8E8E8"),
                       axis.text.x=element_blank(),          
                       axis.text.y=element_blank(),
                       axis.ticks=element_blank(),
                       axis.text=element_text(size=6),
                       plot.title = element_text(hjust = 0.5, size = 11))
         
         ggplotly(p, tooltip = "text") # tooltip argument to suppress the default information and just show the custom text
     })
    

}


shinyApp(ui = ui, server = server)
