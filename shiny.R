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
    
    titlePanel("World Wine Explorer", 
               windowTitle = "Wine app"),
    sidebarLayout(
        sidebarPanel(
            setSliderColor(c("#96027A", "#96027A"), c(1, 2)),
            width = 3,
            div("This application will help you explore the world of wine!", style = "color: grey; font-size:80%"),
            div("     .", style = "color: #f5f5f5; font-size:80%"),
            div("*Reviews are only published for wines rated 80+ points", style = "color: grey; font-size:80%"),
            div("     .", style = "color: #f5f5f5; font-size:80%"),
            sliderInput("WineRating", 
                        "Select your desired rating range.",
                        min = 80, max = 100, value = c(80,100)), 
            
            pickerInput("WinePriceCategory", 
                        label = "Select your desired price range ($USD).",
                        choices = priceCategory,
                        multiple = TRUE,
                        options = list(`actions-box` = TRUE),
                        selected = priceCategory),
            
            pickerInput("WineCountry", 
                        label = "Choose a Country",
                        choices = country,
                        multiple = TRUE,
                        selected = "Canada"),
            
            pickerInput('WineRegion', 
                        'Region Selection',
                        choices = NULL,
                        multiple = TRUE,
                        options = list(`actions-box` = TRUE),
                        selected = region),
            
            pickerInput("WineVintage", 
                        label = "Choose a Vintage Year",
                        choices = NULL,
                        multiple = TRUE,
                        options = list(`actions-box` = TRUE))),
            
                
        mainPanel(plotlyOutput("map"),
                  fluidRow(
                      column(6,
                             plotlyOutput("variety")),
                      column(6,
                             plotlyOutput("price_rate"))))
        )

    )

server <- function(input, output, session) {
    
  observe(print(input$WineCountry))
  
  # change province choices based on country
  
  observeEvent(input$WineCountry,{
    updateSelectInput(session,'WineRegion',
                           choices = data %>% 
                              filter(country %in% input$WineCountry) %>%
                              distinct(region_1))
  })
  
  observeEvent(c(input$WineCountry,input$WineRegion),{
    updatePickerInput(session,'WineVintage',
                      choices = data %>% 
                        filter(country %in% input$WineCountry,
                               region_1 %in% input$WineRegion) %>%
                        distinct(vintage) %>% 
                        arrange(desc(vintage)))
  })
  
    
    data_filter <- reactive({
      if(is.null(input$WineRegion) & 
         is.null(input$WineVintage)) {data %>% filter(points > input$WineRating[1],
                                                      points < input$WineRating[2],
                                                      priceCategory %in% input$WinePriceCategory,
                                                      country == input$WineCountry)
        
      } else if (is.null(input$WineRegion)){data %>% 
                                                filter(points > input$WineRating[1],
                                                       points < input$WineRating[2],
                                                       priceCategory %in% input$WinePriceCategory,
                                                       country == input$WineCountry,
                                                       vintage %in% input$WineVintage)
        
      } else if(is.null(input$WineVintage)){data %>% 
                                                  filter(points > input$WineRating[1],
                                                         points < input$WineRating[2],
                                                         priceCategory %in% input$WinePriceCategory,
                                                         country == input$WineCountry,
                                                         region_1 %in% input$WineRegion)
        
      } else{
              data %>% 
                filter(points > input$WineRating[1],
                       points < input$WineRating[2],
                       priceCategory %in% input$WinePriceCategory,
                       country == input$WineCountry,
                       region_1 %in% input$WineRegion,
                       vintage %in% input$WineVintage)
        }})
  
    
    output$map <- renderPlotly(
        full_data %>% #filter(country.x == input$WineCountry) %>% 
        plot_geo() %>%
            add_trace(
                z = ~avg_rating,
                color = ~avg_rating, 
                colors = 'RdPu',
                text = full_data$my_text, 
                locations = ~countrycodes, 
                marker = list(line = list(color = toRGB("grey"), width = 0.5)),
                hoverinfo = "text"
            ) %>%
            layout(
                title = 'Average Wine Ratings by Country',
                geo = list(showframe = FALSE,
                           showcoastlines = FALSE,
                           projection = list(type = 'Mercator'))
            ) %>% 
        colorbar(thickness = 15, len = 1,
                 title = "Average<BR>Rating", 
                 outlinecolor = "#EEEEEE",
                 nticks = 4,
                 titlefont = list(size = 10), 
                 tickfont = list(size = 8))
          )
    
    output$variety <- renderPlotly({
            
            # Prep filtered data for plot
            varieties_table <- data_filter() %>% 
                select(variety, points) %>% 
                group_by(variety) %>% 
                summarise(avg_points = mean(points)) %>% 
                filter(variety != "") %>% 
                arrange(desc(avg_points)) %>% 
                top_n(10)
            
            # Display message if no data selected
            validate(need(varieties_table$variety, message = "No wines selected"))
            
            # Draw Plot           
            varieties_table %>% 
              plot_ly(x = ~avg_points, 
                        y = ~variety,
                        color = ~avg_points, 
                        type = 'bar',
                        colors = 'RdPu',
                        orientation = 'h',
                        text = ~paste("Average rating: ", round(avg_points,0)),
                        textposition = 'outside',
                      textfont = list(color = "#FFFFFF"),
                      hoverinfo = 'text'
                      ) %>% 
                layout(xaxis = list(range = c(80, 100), title = "Average Rating"), 
                       yaxis = list(categoryarray = ~variety, categoryorder = "array",
                                    title = "", tickangle = 0), 
                       font = list(size = 10),
                       title = "Which Varieties have the highest ratings?"
                       ) %>% 
              hide_colorbar()
    }) 



     output$price_rate <- renderPlotly({
       
         # Display message if no data selected
        validate(need(data_filter()$points, message = "No wines selected"))
       
         # build plot with ggplot syntax
         p <- data_filter() %>%
                 ggplot(aes(x = points,
                            y = price,
                            color = "#96027A",
                            text = paste("Title: ", title_wrapped, 
                                         "<BR>", "Price: $",  price,
                                         "<BR>", "Rating: ", points, "points", 
                                        "<BR>", "Variety: ", variety,
                                         sep = ""))) +
                 geom_jitter(alpha = .5, color = "#96027A", width = .15) +
                 theme_bw() +
                 labs(title = "Price vs. Ratings", x = "Rating (score out of 100)", y = "Price (USD)" ) +
                 theme(legend.position="none",
                       panel.border = element_blank(),
                       panel.grid.major = element_blank(),
                       panel.grid.minor = element_blank(),
                       axis.line = element_line(colour = "#E8E8E8"),
                       axis.ticks=element_blank(),
                       axis.text=element_text(size=8),
                       axis.title.x = element_text(size= 9, colour = '#5a5a5a'),
                       axis.title.y = element_text(size = 9, colour = '#5a5a5a'),
                       plot.title = element_text(hjust = 0.5, size = 11, colour = '#5a5a5a'))
         
         ggplotly(p, tooltip = "text") # tooltip argument to suppress the default information and just show the custom text
     })
    

}


shinyApp(ui = ui, server = server)
