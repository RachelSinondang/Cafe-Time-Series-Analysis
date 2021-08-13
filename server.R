#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$plot_period <- renderPlotly({
        
        bread_1 <- bread  %>%
            group_by(Item, period_day, weekday_weekend) %>%
            summarise(total = n())
        
        period_plot <- ggplot(bread_1 %>% filter(Item == input$item1 | Item == input$item2 | Item == input$item3 | Item == input$item4), aes(x=weekday_weekend, y=total, fill=period_day, text = glue("{period_day}
                                                                                                                                                             total: {total}"))) + geom_col() + facet_grid(.~Item) + theme_algoritma +
            labs(title = NULL,
                 x = NULL,
                 y = "Total Items") 
        
        ggplotly(period_plot, tooltip = "text") %>% layout(showlegend = FALSE)
        
        
    })
    
    output$plot_heat <- renderPlotly({
        
        bread_1 <- bread  %>%
            group_by(Item, period_day, weekday_weekend) %>%
            summarise(total = n())
        
        total <- bread %>%
            group_by(date,Item) %>%
            summarise(total = n())
        
        t_week <- cut(total$date, "week")
        t_weekly <- aggregate(total ~ t_week+Item, total, mean)
        
        weekly <- t_weekly %>% mutate(t_week = as.Date(t_week),
                                      total = round(total),
                                      month = month(t_week))
        
        heat_map <- ggplot(weekly %>%  filter(Item == input$itm1 | Item == input$itm2 | Item == input$itm3 | Item == input$itm4), aes(t_week, Item, fill= total, text = glue("month: {month}
                                                                                                                                                                                              total: {total}"))) + 
            geom_tile()+
            scale_fill_viridis(discrete=FALSE)+theme_algoritma+
            labs(title = NULL,
                 x = NULL,
                 y = NULL) 
        
        ggplotly(heat_map, tooltip = "text")
        
        
    })
    
    output$plot_tree <- renderPlot({
        
        bread_1 <- bread  %>%
            group_by(Item, period_day, weekday_weekend) %>%
            summarise(total = n())
        
        total <- bread %>%
            group_by(date,Item) %>%
            summarise(total = n())
        
        month <- cut(total$date, "month")
        monthly <- aggregate(total ~ month+Item, total, sum)
        
        monthly_mean <- monthly %>%
            group_by(Item) %>%
            summarise(rerata = mean(total)) %>%
            arrange(desc(rerata)) %>%
            mutate(rerata = round(rerata))
        
        ggplot(monthly_mean, aes(area = rerata, fill = rerata,
                                 label = paste(Item, rerata, sep = "\n"))) +
            geom_treemap(show.legend = F) +
            geom_treemap_text(colour = "white",
                              place = "centre",
                              size = 15)
        
        
    })
    
    output$plot_time <- renderPlot({
        
        daily <- bread %>% 
            group_by(date) %>%
            summarise(total = n()) 
        
        daily <- daily %>% 
            mutate(total = na.fill(total, fill = "extend"))
        
        daily_1 <- daily %>%
            mutate(wday = wday(date),
                   total = round(total))
        
        ggplot(data = daily_1, aes(x = date, y = total))+
            geom_point( col = "blue")+
            geom_point( data = daily_1 %>% 
                            filter(wday == "1"), col = "red")+
            geom_line() + theme_algoritma +
            labs(title = NULL,
                 x = "Date",
                 y = "Total Items") 
        
        
    })
    
    output$plot_auto <- renderPlot({
        
        daily <- bread %>% 
            group_by(date) %>%
            summarise(total = n()) 
        
        daily <- daily %>% 
            mutate(total = na.fill(total, fill = "extend"))
        
        bread_msts <- daily$total %>% 
            msts(seasonal.periods = c(7,4*7),start = ymd("2016-10-30"))
        
        bread_train <- bread_msts %>% head(length(bread_msts) - 2*4*7)
        bread_test <- bread_msts %>% tail(2*4*7)
        
        bread_arima <- stlm(bread_train, method = "arima", allow.multiplicative.trend = T)
        
        arima_f <- forecast(bread_arima, h = input$num, allow.multiplicative.trend = T)
        
        
        
        bread_train %>% tail(4*7) %>% 
            autoplot()+
            autolayer(bread_test, series = "test")+
            autolayer(bread_arima$fitted %>% tail(4*7), series = "fitted_arima")+
            autolayer(arima_f$mean, series = "forecast_arima") + theme_algoritma
        
    })
    
    output$dailyBox <- renderValueBox({
        
        daily <- bread %>% 
            group_by(date) %>%
            summarise(total = n()) 
        
        daily <- daily %>% 
            mutate(total = na.fill(total, fill = "extend"))
        
        bread_msts <- daily$total %>% 
            msts(seasonal.periods = c(7,4*7),start = ymd("2016-10-30"))
        
        bread_train <- bread_msts %>% head(length(bread_msts) - 2*4*7)
        bread_test <- bread_msts %>% tail(2*4*7)
        
        bread_arima <- stlm(bread_train, method = "arima", allow.multiplicative.trend = T)
        
        arima_f <- forecast(bread_arima, h = input$num, allow.multiplicative.trend = T)
        
        
        valueBox(value = round(arima_f$mean[input$day]),
                 subtitle = "Prediction",
                 color = "purple")
        
    })

})
