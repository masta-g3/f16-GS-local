library(shiny)
library(dplyr)
library(tidyr)
library(highcharter)
#library(rCharts)
#library(rNVD3)
library(reshape)
library(stringr)
library(broom)

#setwd('/home/hs2865/src/f16-GS/capstone_app')
setwd('/Users/manuelrueda/Dropbox/Documents/python/f16-GS/capstone_app')

## Read data.
companies <- read.csv('cik_new.csv', header=FALSE, sep='|', stringsAsFactors = FALSE)
colnames(companies) <- c('Company.Name', 'CIK') 
companies <- companies[!duplicated(companies[,'CIK']),]
data <- read.csv("results-best.csv")

## Clean and format.
data <- unique(data)
colnames(data) <- c('CIK', 'Jaccard', 'TF-IDF', 'Word2Vec', 'Common Words', 'Deleted Words','New Words', 'Total Words', 'Top Words', 'Year')
data[,c(2:7)] = round(data[,c(2:7)],2)
data$CIK <- sprintf('%010d', data$CIK)

data <- merge(x = data, y = companies[,c('CIK', 'Company.Name')], by = "CIK", all.x = TRUE)

## Normalize word2vec.
data$Word2Vec <- round(data$Word2Vec / max(data$Word2Vec),2)
## Get means.
means <- round(colMeans(data[,c('Jaccard','TF-IDF','Word2Vec')]),2)
## Get IDs.
#mapping <- seq(length(unique(data$Company.Name)))
#names(mapping) <- unique(data$Company.Name)
#data$Id <- mapping[data$Company.Name]

## Filled heatmap dataset.
all_years = c(2008,2009,2010,2011,2012,2013,2014,2015)
all_companies <- unique(data$CIK)
#filled_data <- data[, c('Year', 'Id', 'CIK', 'Company.Name', 'Jaccard', 'TF-IDF', 'Word2Vec')]
filled_data <- data[, c('Year', 'CIK', 'Company.Name', 'Jaccard', 'TF-IDF', 'Word2Vec')]

for(company in all_companies) {
  tmp_data <- data[data$CIK == company, c('Year', 'CIK', 'Company.Name', 'Jaccard', 'TF-IDF', 'Word2Vec')]
  missing_years = setdiff(all_years, unique(tmp_data$Year))
  name <- unique(tmp_data$Company.Name)
  cik <- unique(tmp_data$CIK)
  for(year in missing_years) {
    new_row = c(year, cik, name, means[1], means[2], means[3])
    filled_data = rbind(filled_data, new_row)
  }
}
filled_data <- arrange(filled_data, CIK, Year)
update.cols <- c('Year','Jaccard', 'TF-IDF', 'Word2Vec')
filled_data[update.cols] <- sapply(filled_data[update.cols],as.numeric)


## Get IDs.
mapping <- seq(length(unique(filled_data$Company.Name)))
names(mapping) <- unique(filled_data$Company.Name)
filled_data$Id <- mapping[filled_data$Company.Name]
data$Id <- mapping[data$Company.Name]


## Get list of all companies and CIKs.
cik_map <- unique(data[c('CIK','Company.Name')])

shinyServer(function(input, output, session) {
  values <- reactiveValues(company = '0000005981')
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
      hc_yAxis(max = 1) %>%
      #hc_yAxis(title = list(text = "Weights")) %>% 
      # hc_plotOptions(column = list(
      #   dataLabels = list(enabled = FALSE),
      #   stacking = "normal",
      #   enableMouseTracking = FALSE)
      # ) %>% 
      hc_xAxis(categories = distance()$Year) %>% 
      hc_add_series(name="Jaccard", data=distance()$Jaccard) %>%
      hc_add_series(name="TF-IDF", data=distance()$`TF-IDF`) %>%
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
      hc_add_series(name="Deleted Words", data=changes()$`Deleted Words`, color='#444349') %>%
      hc_add_series(name="New Words", data=changes()$`New Words`, color='#A4EA8A') %>%
      hc_add_series(name="Common Words", data=changes()$`Common Words`, color='#86B4E6')
    plot2
  })
  
  output$heatmap <- renderHighchart({
    heatmap <- highchart() %>%
      hc_chart(type = "heatmap")
      #hc_title(text = "Simulated values by years and months") %>%
      #hc_xAxis(categories = data$Company.Name) %>%
    if(input$map.type == 'Jaccard') {
      heatmap <- heatmap %>%
        hc_add_series(name = "Jaccard", data = list_parse2(filled_data[,c('Year','Id','Jaccard')]))
    } else if(input$map.type == 'TF-IDF') {
      heatmap <- heatmap %>%
        hc_add_series(name = "TF-IDF", data = list_parse2(filled_data[,c('Year','Id','TF-IDF')]))
    } else if (input$map.type == 'Word2Vec') {
      heatmap <- heatmap %>%
        hc_add_series(name = "Word2Vec", data = list_parse2(filled_data[,c('Year','Id','Word2Vec')]))
    }
    heatmap <- heatmap %>%
      hc_yAxis(categories = c('CIK', names(mapping))) %>%
      hc_colorAxis(minColor = "#ffd3b6", maxColor = "#ff8b94")
    
    heatmap
  })
  
  
  #output$heatmap2 <- renderHighchart({
  #  heatmap <- highchart() %>%
  #    hc_chart(type = "heatmap") %>%
  #    #hc_title(text = "Simulated values by years and months") %>%
  #    #hc_xAxis(categories = data$Company.Name) %>%
  #    hc_yAxis(categories = c('Company.Name', names(mapping))) %>%
  #    hc_add_series(name = "Word2Vec", data = list_parse2(data[,c('Year','Id','Word2Vec')]))
  #  hc_colorAxis(heatmap, minColor = "#ffeda0", maxColor = "#f03b20")
  #})  
  
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
  
  output$tab3 <- DT::renderDataTable(
    DT::datatable(cik_map)
  )
  
  output$tit <- renderText(
    dataset()[dataset()$CIK == values$company, 'Company.Name'][1]
  )
  
  ## Send plots to UI.
  #plot2 %>% bind_shiny("word_dist")
})

