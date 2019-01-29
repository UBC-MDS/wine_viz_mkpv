library(shiny)
library(tidyverse)
library(countrycode)
library(ggplot2)
library(shinyWidgets)
library(plotly)
library(viridisLite)
library(beeswarm)
library(ggbeeswarm)
library(dplyr)

# run the data wrangling script
# this allows an updated file to be used without requiring any manual wrangling
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
                        options = list(`actions-box` = TRUE),
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
  
  # Returns the points and price variables of the efficiency frontier for data
  get_efficiency_frontier <- function(data){
    # Get convex hull around the data
    ch <- chull(data$points, data$price)
    ch_data = data[ch, c("points", "price")]
    
    # Find the start and end points for the efficiency frontier
    # Note: 'data$points' is the wine rating variable... not all the data points
    frontier_start_points <- min(ch_data$points)
    frontier_start_price <- min(ch_data[ch_data$points == frontier_start_points, ]$price)
    frontier_end_points <- max(ch_data$points)
    frontier_end_price <- min(ch_data[ch_data$points == frontier_end_points, ]$price)
    x <- c(frontier_start_points, frontier_end_points)
    y <- c(frontier_start_price, frontier_end_price)
    
    # Formula for trimming line so we can keep just the lower part of the convex hull
    lm <- broom::tidy(lm(y ~ x))
    intercept = lm[[1, 'estimate']]
    slope = lm[[2, 'estimate']]
    
    # Trim the convex hull to get our efficiency frontier
    efficiency_frontier <- ch_data %>% 
      filter(price <= points * slope + intercept + 1) %>% 
      arrange(points)
    return(efficiency_frontier)
  }
    
  
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
      #req(input$WineCountry)
      if(is.null(input$WineRegion) & 
         is.null(input$WineVintage)) {data %>% filter(points > input$WineRating[1],
                                                      points < input$WineRating[2],
                                                      priceCategory %in% input$WinePriceCategory,
                                                      country %in% input$WineCountry)
        
      } else if (is.null(input$WineRegion)){data %>% 
                                                filter(points > input$WineRating[1],
                                                       points < input$WineRating[2],
                                                       priceCategory %in% input$WinePriceCategory,
                                                       country %in% input$WineCountry,
                                                       vintage %in% input$WineVintage)
        
      } else if(is.null(input$WineVintage)){data %>% 
                                                  filter(points > input$WineRating[1],
                                                         points < input$WineRating[2],
                                                         priceCategory %in% input$WinePriceCategory,
                                                         country %in% input$WineCountry,
                                                         region_1 %in% input$WineRegion)
        
      } else{
              data %>% 
                filter(points > input$WineRating[1],
                       points < input$WineRating[2],
                       priceCategory %in% input$WinePriceCategory,
                       country %in% input$WineCountry,
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
        validate(
          need(data_filter()$points, message = "No wines selected")
          )
       
       p <- ggplot(data = data_filter()) +
         geom_path(data = get_efficiency_frontier(data_filter()), 
                   aes(points, price), 
                   alpha=0.5, 
                   color = "blue", 
                   size = 1) +
         geom_beeswarm(aes(points, price,
                           text = paste(title_wrapped, 
                                        "<BR>$",  price,
                                        "<BR>", points, " points", 
                                        "<BR>", variety,
                                        sep = "")), 
                       color = "#96027A", 
                       alpha = 0.5,
                       cex = 1.1, 
                       size = 1.5) +
         theme_bw() +
         labs(title = "Price vs. Ratings", x = "Rating (score out of 100)", y = "Price (USD)" ) +
         scale_y_continuous(
           labels = scales::number_format(accuracy = 0.1)) +
         scale_x_continuous(
           labels = scales::number_format(accuracy = 0.1)) +
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
