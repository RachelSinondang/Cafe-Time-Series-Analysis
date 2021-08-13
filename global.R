library(shiny)
library(shinydashboard)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(treemap)
library(plotly)
library(glue)
library(viridis)
library(treemapify)
library(forecast) # time series library
library(TTR) # for Simple moving average function
library(MLmetrics) # calculate error
library(tseries) # adf.test
library(fpp) # usconsumtion
library(padr)
library(zoo)

theme_algoritma <- theme(legend.key = element_rect(fill="black"),
                         legend.background = element_rect(color="white", fill="#263238"),
                         plot.subtitle = element_text(size=6, color="white"),
                         panel.background = element_rect(fill="#dddddd"),
                         panel.border = element_rect(fill=NA),
                         panel.grid.minor.x = element_blank(),
                         panel.grid.major.x = element_blank(),
                         panel.grid.major.y = element_line(color="darkgrey", linetype=2),
                         panel.grid.minor.y = element_blank(),
                         plot.background = element_rect(fill="#263238"),
                         text = element_text(color="white"),
                         axis.text = element_text(color="white")
                         
)

bread <- read.csv("bread_basket.csv")

bread <- bread %>%
  mutate(Item = as.factor(Item),
         date_time = dmy_hm(date_time),
         period_day = as.factor(period_day),
         weekday_weekend = as.factor(weekday_weekend))

bread$hour_time <- floor_date(bread$date_time, "hour")

bread$date <- date(bread$date_time)

bread_1 <- bread  %>%
  group_by(Item, period_day, weekday_weekend) %>%
  summarise(total = n())