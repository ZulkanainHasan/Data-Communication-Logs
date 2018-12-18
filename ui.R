require(highcharter)
library(DT)

shinyUI(navbarPage(
  "Data Communication Logs",
  tabPanel("Scatterplot",
             fluidPage(
               highchartOutput("scatterplot")
             )),
  
  tabPanel("Dataset",
           fluidPage(
             DT::dataTableOutput("dataTable")
           )),
  
  tabPanel("Documentation")
  
  )
)

# debugging on console
# rsconnect::showLogs()