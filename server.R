require(highcharter)
library(dplyr)
library(DT)

dataset <- tbl_df(read.csv("MH370-Data-Log.csv"))

# quick patch row selection. dplyr::filter got issue
dataset <- dataset[dataset$Type == "data", ]

# select required columns
dataset <- dataset %>% 
  select(Time, Channel.Unit.ID, Channel.Type, 
         Burst.Frequency.Offset..Hz..BFO, 
         Burst.Timing.Offset..microseconds..BTO) 

# simplify column names better typing
rename_col <- c("time", "channel_id", "channel_type", "BFO", "BTO")
names(dataset)[1:5] <- rename_col

# convert column channel_id from double to integer
dataset$channel_id <- as.integer(dataset$channel_id)

# refactor column channel_type
dataset$channel_type <-  factor(dataset$channel_type, 
                                levels = c("C-Channel RX", "P-Channel TX", "R-Channel RX", "T-Channel RX"),
                                labels = c("C-RX", "P-TX", "R-RX", "T-RX"))

# replace NA with 0
dataset$BTO[is.na(dataset$BTO)] <- 0
dataset$BFO[is.na(dataset$BFO)] <- 0

# convert datetime to POSIXct
dataset$time <- as.POSIXct(strptime(as.character(dataset$time), 
                                    "%d/%m/%Y %H:%M:%OS"))



#------------------------------------------------


shinyServer(function(input, output) {
  output$xlim_ui <- renderUI({
    if (is.null(input$mean)) {
      return()
    }
    sliderInput(
      "xlim",
      label = "xlim",
      min = input$mean,
      max = 10,
      value = input$mean,
      step = 1
    )
  })
  
  output$scatterplot <- renderHighchart({
    highchart() %>% 
      hc_title(text = "Scatterplot for Time Vs BFO") %>% 
      hc_xAxis(type = "datetime") %>% 
      hc_add_series_scatter(datetime_to_timestamp(dataset$time), 
                            dataset$BFO, color = dataset$channel_type)
  })
  
  output$dataTable <- DT::renderDataTable({
    datatable(dataset)
  
  })
}
)