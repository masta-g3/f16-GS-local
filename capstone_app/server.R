library(shiny)
library(dplyr)
library(tidyr)
library(highcharter)
#library(rCharts)
#library(rNVD3)
library(reshape)
library(stringr)
library(broom)
library(zoo)   


#setwd('/home/hs2865/src/f16-GS/capstone_app')
setwd('/Users/manuelrueda/Dropbox/Documents/python/f16-GS/capstone_app')
data <- read.csv("results3.csv")
colnames(data) <- c('CIK', 'Jaccard', 'TF-IDF', 'Word2Vec', 'Common Words', 'Deleted Words','New Words', 'Total Words', 'Top Words', 'Year')
data[,c(2,3,4,5)] = round(data[,c(2,3,4,5)],2)
companies = read.csv('company_list.csv', stringsAsFactors=F)

all_years = c(2008,2009,2010,2011,2012,2013,2014,2015)
data <- merge(x = data, y = companies[,c('CIK', 'Company.Name')], by = "CIK", all.x = TRUE)

shinyServer(function(input, output, session) {
  values <- reactiveValues(company = '1053352')
  # Fill in the spot we created for a plot
  observeEvent(input$go, {
    values$company <- input$cik
  })
  
  dataset <- reactive({
    data[data$CIK == values$company,]
  })
  
  # output$plot1 <- renderPlot({
  #   ggplot(data=distance, aes(x=Year, y=value, fill=Measure)) + 
  #     geom_bar(colour="black", stat="identity",
  #              position=position_dodge(),
  #              width = .5, size=.3) +                        # Thinner lines
  #     scale_fill_manual(values=c("#31a354", "#2c7fb8"), name = "Measures: \n") +
  #     xlab("Years") + ylab("Cosine & Jaccard distance") + # Set axis labels
  #     theme_bw() + ylim(0,1) +
  #     theme(
  #       #plot.background = element_blank()
  #       #panel.grid.major = element_blank()
  #       panel.grid.minor = element_blank()
  #       ,panel.border = element_blank(),
  #       axis.line.x = element_line(color="black", size = .5),
  #       axis.line.y = element_line(color="black", size = .5),
  #       axis.text=element_text(size=12),
  #       axis.title=element_text(size=14),
  #       legend.text=element_text(size=14),
  #       legend.title = element_text(size = 16, face = 'bold')
  #     ) + scale_x_continuous(breaks = dataset()$Year)    
  # })
  
  distance <- reactive({
    #tf.frame = data.frame(Measure = 'TF-IDF', value = dataset()$`TF-IDF`, Year = dataset()$Year, stringsAsFactors=F)
    #jac.frame = data.frame(Measure = 'Jaccard', value = dataset()$Jaccard, Year = dataset()$Year, stringsAsFactors=F)
    #w2v.frame = data.frame(Measure = 'Word2Vec', value = dataset()$Word2Vec, Year = dataset()$Year, stringsAsFactors=F)
    #distance = rbind(tf.frame, jac.frame)
    #distance = rbind(distance, w2v.frame)
    distance = dataset()[,c("Year","TF-IDF","Jaccard","Word2Vec")]
    missing_years = setdiff(all_years, unique(distance$Year))
     for(year in missing_years) {
       new_row = c(year,0,0,0)
       distance = rbind(distance, new_row)
     }
    arrange(distance, Year)
  })
  
  # output$plot1 <- renderChart2({
  #   plot1 <- nPlot(value ~ Year, group='Measure', data = distance(), type = 'multiBarChart', width=600)
  #   plot1$chart(stacked=FALSE, showControls=FALSE, forceY = 1)
  #   plot1$xAxis(tickValues=all_years)
  #   plot1
  # })
  
  output$plot1 <- renderHighchart({
    plot1 <- highchart() %>% 
      hc_chart(type = "column") %>% 
      #hc_yAxis(title = list(text = "Weights")) %>% 
      # hc_plotOptions(column = list(
      #   dataLabels = list(enabled = FALSE),
      #   stacking = "normal",
      #   enableMouseTracking = FALSE)
      # ) %>% 
      hc_xAxis(categories = distance()$Year) %>% 
      hc_add_series(name="TF-IDF", data=distance()$`TF-IDF`) %>%
      hc_add_series(name="Jaccard", data=distance()$Jaccard) %>%
      hc_add_series(name="Word2Vec", data=distance()$Word2Vec)
    plot1
  })
  
  changes <- reactive({
    # new.frame = data.frame(Measure = 'New Words', value = dataset()$`New Words`, Year = dataset()$Year, stringsAsFactors=F)
    # del.frame = data.frame(Measure = 'Deleted Words', value = dataset()$`Deleted Words`, Year = dataset()$Year, stringsAsFactors=F)
    # com.frame = data.frame(Measure = 'Common Words', value = dataset()$`Common Words`, Year = dataset()$Year, stringsAsFactors=F)
    # changes = rbind(new.frame, del.frame)
    # changes = rbind(changes, com.frame)
    # missing_years = setdiff(all_years, unique(changes$Year))
    # for(year in missing_years) {
    #   new_row <- c('New Words', 0, year)
    #   changes <- rbind(changes, new_row)
    #   del_row <- c('Deleted Words', 0, year)
    #   changes <- rbind(changes, del_row)
    #   com_row <- c('Common Words', 0, year)
    #   changes <- rbind(changes, com_row)
    # }
    # arrange(changes, Year, Measure)
    changes = dataset()[,c("Year","Common Words","New Words","Deleted Words")]
    missing_years = setdiff(all_years, unique(changes$Year))
    for(year in missing_years) {
      new_row = c(year,0,0,0)
      changes = rbind(changes, new_row)
    }
    arrange(changes, Year)
  })
  
  output$plot2 <- renderHighchart({
    plot2 <- highchart() %>% 
      hc_chart(type = "column") %>% 
      #hc_yAxis(title = list(text = "Weights")) %>% 
      hc_plotOptions(column = list(stacking = "normal")) %>%
      hc_xAxis(categories = changes()$Year) %>% 
      hc_yAxis(max = 1) %>%
      hc_add_series(name="Common Words", data=changes()$`Common Words`) %>%
      hc_add_series(name="New Words", data=changes()$`New Words`) %>%
      hc_add_series(name="Deleted Words", data=changes()$`Deleted Words`)
    plot2
  })
  
  #output$plot2 <- renderPlot({
  # output$plot2 <- renderChart2({
  #   plot2 <- nPlot(value ~ Year, group='Measure', data = changes(), type = 'multiBarChart', width=600)
  #   plot2$chart(stacked=TRUE, showControls=TRUE, forceY=1)
  #   plot2$xAxis(tickValues=all_years)
  #   #plot2$set(dom = "plot2")
  #   plot2
  # })
  
  #plot2 <- reactive({
  #  distance() %>% ggvis(x=~Year, y=~value, fill=~Measure) %>%
  #    group_by(Measure) %>%
  #    layer_bars() %>%
  #    add_axis("x", title="Year",  format="####")
  #})
  
    # ggplot(data=distance, aes(x=Year, y=value, fill=Measure, label = value)) + 
    #   geom_bar(colour="black", stat="identity",
    #            width = .5, size=.3) +  
    #   geom_text(size = 4, position = position_stack(vjust = 0.5), col = 'white') + 
    #   scale_fill_manual(values=c("#31a354", "#2c7fb8"), name = "Measures: \n") +
    #   xlab("Years") + ylab("Share") + # Set axis labels
    #   theme_bw() + ylim(0,1) +
    #   theme(
    #     #plot.background = element_blank()
    #     #panel.grid.major = element_blank()
    #     panel.grid.minor = element_blank()
    #     ,panel.border = element_blank(),
    #     axis.line.x = element_line(color="black", size = .5),
    #     axis.line.y = element_line(color="black", size = .5),
    #     axis.text=element_text(size=12),
    #     axis.title=element_text(size=14),
    #     legend.text=element_text(size=14),
    #     legend.title = element_text(size = 16, face = 'bold')
    #   ) + scale_x_continuous(breaks = dataset()$Year)
  #})
  
  output$tab1 <- DT::renderDataTable(
    DT::datatable(dataset()[,c('CIK', 'Year','Jaccard', 'TF-IDF', 'Deleted Words','New Words', 'Top Words')])
  )

  output$tab2 <- DT::renderDataTable(
    DT::datatable(data[,c('CIK', 'Year','Jaccard', 'TF-IDF', 'Deleted Words','New Words', 'Top Words')])
  )
  
  output$tit <- renderText(
    dataset()[dataset()$CIK == values$company, 'Company.Name'][1]
  )
  
  ## Send plots to UI.
  #plot2 %>% bind_shiny("word_dist")
})