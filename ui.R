#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

header <- dashboardHeader(title = "Cafe Sales Forecast")

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(text = "Bussiness Case", 
                 tabName = "case", 
                 icon = icon("file-invoice-dollar")),
        menuItem(text = "Plot", 
                 tabName = "graph", 
                 icon = icon("chart-bar")),
        menuItem(text = "Prediction", 
                 tabName = "predict", 
                 icon = icon("balance-scale"))
        
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "graph",
                fluidRow(
                    box(title = "Item sold by time period",
                        background = "teal",
                        height = "550px",
                        width = 12,
                        fluidRow(column(3,
                                        selectInput(inputId = "item1", 
                                                    label = "Item 1",
                                                    choices = unique(bread_1$Item))),
                                 column(3,
                                        selectInput(inputId = "item2", 
                                                    label = "Item 2",
                                                    choices = unique(bread_1$Item))),
                                 column(3,
                                        selectInput(inputId = "item3", 
                                                    label = "Item 3",
                                                    choices = unique(bread_1$Item))),
                                 column(3,
                                        selectInput(inputId = "item4", 
                                                    label = "Item 4",
                                                    choices = unique(bread_1$Item)))),
                        fluidRow(column(width = 12,plotlyOutput(outputId = "plot_period"))
                    )
                )
        ),
        fluidRow(
            box(title = "Weekly total old by Item",
                background = "teal",
                height = "550px",
                width = 12,
                fluidRow(column(3,
                                selectInput(inputId = "itm1", 
                                            label = "Item 1",
                                            choices = unique(bread_1$Item))),
                         column(3,
                                selectInput(inputId = "itm2", 
                                            label = "Item 2",
                                            choices = unique(bread_1$Item))),
                         column(3,
                                selectInput(inputId = "itm3", 
                                            label = "Item 3",
                                            choices = unique(bread_1$Item))),
                         column(3,
                                selectInput(inputId = "itm4", 
                                            label = "Item 4",
                                            choices = unique(bread_1$Item)))),
                fluidRow(column(width = 12,plotlyOutput(outputId = "plot_heat"))
                )
            )
        ),
        fluidRow(
            box(
                title = "Total Item Sold", width = 6, background = "teal",
                plotOutput(outputId = "plot_tree")
            ),
            box(
                title = "Daily Total Sold", width = 6, background = "teal",
                plotOutput(outputId = "plot_time")
            )
        )
    ),
    tabItem(tabName = "predict", 
            numericInput("num", 
                         label = "Days", 
                         value = 28,
                         min = 28,
                         step = 7),
            fluidRow(plotOutput(outputId = "plot_auto")),
            fluidRow(column(4,numericInput("day", 
                                  label = "Forecasted day", 
                                  value = 1,
                                  min = 1,
                                  step = 1)),
            column(8, valueBoxOutput("dailyBox")))
    )
))





dashboardPage(
    header = header,
    body = body,
    sidebar = sidebar, 
    skin = "red"
)
