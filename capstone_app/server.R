library(shiny)
library(dplyr)
library(tidyr)
library(stringr)
library(highcharter)

#setwd('/home/hs2865/src/f16-GS/capstone_app')
#setwd('/Users/manuelrueda/Dropbox/Documents/python/f16-GS/capstone_app')

## Read data.
#companies <- read.csv('cik_new.csv', header=FALSE, sep='|', stringsAsFactors = FALSE)
companies <- read.csv('cik_sample.csv', stringsAsFactors = FALSE)
colnames(companies) <- c('Company.Name', 'CIK') 
companies$CIK <- sprintf('%010d', companies$CIK)
companies <- companies[!duplicated(companies[,'CIK']),]
risk_data <- read.csv("risk_data.csv")
business_data <- read.csv("business_data.csv")

## Clean and format risk.
risk_data <- unique(risk_data)
colnames(risk_data) <- c('CIK', 'Jaccard', 'TF-IDF', 'Word2Vec', 'Common.Words', 'Deleted.Words','New.Words', 'Total.Words', 'Top.Words', 'Year')
risk_data[,c(2:7)] = round(risk_data[,c(2:7)],2)
risk_data$CIK <- sprintf('%010d', risk_data$CIK)

risk_data <- merge(x = risk_data, y = companies[,c('CIK', 'Company.Name')], by = "CIK", all.x = TRUE)

## Clean and format business.
business_data <- unique(business_data)
colnames(business_data) <- c('CIK', 'Jaccard', 'TF-IDF', 'Word2Vec', 'Common.Words', 'Deleted.Words','New.Words', 'Total.Words', 'Top.Words', 'Year')
business_data[,c(2:7)] = round(business_data[,c(2:7)],2)
business_data$CIK <- sprintf('%010d', business_data$CIK)

business_data <- merge(x = business_data, y = companies[,c('CIK', 'Company.Name')], by = "CIK", all.x = TRUE)

## Remove 2007.
risk_data <- risk_data[risk_data$Year != 2007,]
business_data <- business_data[business_data$Year != 2007,]

## Normalize word2vec.
risk_data$Word2Vec <- round(risk_data$Word2Vec / max(risk_data$Word2Vec),2)
business_data$Word2Vec <- round(business_data$Word2Vec / max(business_data$Word2Vec),2)

## Get means.
means <- round(colMeans(risk_data[,c('Jaccard','TF-IDF','Word2Vec')]),2)
means <- round(colMeans(business_data[,c('Jaccard','TF-IDF','Word2Vec')]),2)
## Get IDs.
#mapping <- seq(length(unique(data$Company.Name)))
#names(mapping) <- unique(data$Company.Name)
#data$Id <- mapping[data$Company.Name]

## Filled heatmap dataset.
all_years = c(2008,2009,2010,2011,2012,2013,2014,2015)
all_companies <- unique(risk_data$CIK)

filled_risk <- risk_data[, c('Year', 'CIK', 'Company.Name', 'Jaccard', 'TF-IDF', 'Word2Vec')]
filled_business <- business_data[, c('Year', 'CIK', 'Company.Name', 'Jaccard', 'TF-IDF', 'Word2Vec')]

## Filled Risk.
for(company in all_companies) {
  tmp_data <- risk_data[risk_data$CIK == company, c('Year', 'CIK', 'Company.Name', 'Jaccard', 'TF-IDF', 'Word2Vec')]
  missing_years = setdiff(all_years, unique(tmp_data$Year))
  name <- unique(tmp_data$Company.Name)
  cik <- unique(tmp_data$CIK)
  for(year in missing_years) {
    new_row = c(year, cik, name, means[1], means[2], means[3])
    filled_risk = rbind(filled_risk, new_row)
  }
}
filled_risk <- arrange(filled_risk, CIK, Year)
update.cols <- c('Year','Jaccard', 'TF-IDF', 'Word2Vec')
filled_risk[update.cols] <- sapply(filled_risk[update.cols],as.numeric)

## Filled Business.
for(company in all_companies) {
  tmp_data <- business_data[business_data$CIK == company, c('Year', 'CIK', 'Company.Name', 'Jaccard', 'TF-IDF', 'Word2Vec')]
  missing_years = setdiff(all_years, unique(tmp_data$Year))
  name <- unique(tmp_data$Company.Name)
  cik <- unique(tmp_data$CIK)
  for(year in missing_years) {
    new_row = c(year, cik, name, means[1], means[2], means[3])
    filled_business = rbind(filled_business, new_row)
  }
}
filled_business <- arrange(filled_business, CIK, Year)
update.cols <- c('Year','Jaccard', 'TF-IDF', 'Word2Vec')
filled_business[update.cols] <- sapply(filled_business[update.cols],as.numeric)

## Get IDs.
mapping_risk <- seq(length(unique(filled_risk$Company.Name)))
names(mapping_risk) <- unique(filled_risk$Company.Name)

filled_risk$Id <- mapping_risk[filled_risk$Company.Name]
risk_data$Id <- mapping_risk[risk_data$Company.Name]

mapping_business <- seq(length(unique(filled_business$Company.Name)))
names(mapping_business) <- unique(filled_business$Company.Name)

filled_business$Id <- mapping_business[filled_business$Company.Name]
business_data$Id <- mapping_business[business_data$Company.Name]

## Get list of all companies and CIKs.
cik_map <- unique(risk_data[c('CIK','Company.Name')])

## Word Analytics.
#risk_data %>%
#  select(Top.Words) %>%
#  separate(Top.Words, as.character(seq(10)), sep = ",")
#  group_by(CIK)

shinyServer(function(input, output, session) {
  values <- reactiveValues(company = '0001050446')
  # Fill in the spot we created for a plot
  observeEvent(input$go, {
    values$company <- input$cik
  })
  
  risk_dataset <- reactive({
    arrange(risk_data[risk_data$CIK == values$company,], Year)
  })
  
  business_dataset <- reactive({
    arrange(business_data[business_data$CIK == values$company,], Year)
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
  
  risk_distance <- reactive({
    distance = risk_dataset()[,c("Year","TF-IDF","Jaccard","Word2Vec")]
    missing_years = setdiff(all_years, unique(distance$Year))
     for(year in missing_years) {
       new_row = c(year,0,0,0)
       distance = rbind(distance, new_row)
     }
    arrange(distance, Year)
  })
  
  business_distance <- reactive({
    distance = business_dataset()[,c("Year","TF-IDF","Jaccard","Word2Vec")]
    missing_years = setdiff(all_years, unique(distance$Year))
    for(year in missing_years) {
      new_row = c(year,0,0,0)
      distance = rbind(distance, new_row)
    }
    arrange(distance, Year)
  })  
  
  output$risk1 <- renderHighchart({
    plot1 <- highchart() %>% 
      hc_chart(type = "column") %>% 
      hc_yAxis(max = 1) %>%
      #hc_yAxis(title = list(text = "Weights")) %>% 
      # hc_plotOptions(column = list(
      #   dataLabels = list(enabled = FALSE),
      #   stacking = "normal",
      #   enableMouseTracking = FALSE)
      # ) %>% 
      hc_xAxis(categories = risk_distance()$Year) %>% 
      hc_add_series(name="Jaccard", data=risk_distance()$Jaccard) %>%
      hc_add_series(name="TF-IDF", data=risk_distance()$`TF-IDF`) %>%
      hc_add_series(name="Word2Vec", data=risk_distance()$Word2Vec)
    plot1
  })
  
  output$business1 <- renderHighchart({
    plot1 <- highchart() %>% 
      hc_chart(type = "column") %>% 
      hc_yAxis(max = 1) %>%
      #hc_yAxis(title = list(text = "Weights")) %>% 
      # hc_plotOptions(column = list(
      #   dataLabels = list(enabled = FALSE),
      #   stacking = "normal",
      #   enableMouseTracking = FALSE)
      # ) %>% 
      hc_xAxis(categories = business_distance()$Year) %>% 
      hc_add_series(name="Jaccard", data=business_distance()$Jaccard) %>%
      hc_add_series(name="TF-IDF", data=business_distance()$`TF-IDF`) %>%
      hc_add_series(name="Word2Vec", data=business_distance()$Word2Vec)
    plot1
  })  
  
  risk_changes <- reactive({
    changes = risk_dataset()[,c("Year","Common.Words","New.Words","Deleted.Words")]
    missing_years = setdiff(all_years, unique(changes$Year))
    for(year in missing_years) {
      new_row = c(year,0,0,0)
      changes = rbind(changes, new_row)
    }
    arrange(changes, Year)
  })
  
  business_changes <- reactive({
    changes = business_dataset()[,c("Year","Common.Words","New.Words","Deleted.Words")]
    missing_years = setdiff(all_years, unique(changes$Year))
    for(year in missing_years) {
      new_row = c(year,0,0,0)
      changes = rbind(changes, new_row)
    }
    arrange(changes, Year)
  })  
  
  output$risk2 <- renderHighchart({
    plot2 <- highchart() %>% 
      hc_chart(type = "column") %>% 
      #hc_yAxis(title = list(text = "Weights")) %>% 
      hc_plotOptions(column = list(stacking = "normal")) %>%
      hc_xAxis(categories = risk_changes()$Year) %>% 
      hc_yAxis(max = 1) %>%
      hc_add_series(name="Deleted.Words", data=risk_changes()$`Deleted.Words`, color='#444349') %>%
      hc_add_series(name="New.Words", data=risk_changes()$`New.Words`, color='#A4EA8A') %>%
      hc_add_series(name="Common.Words", data=risk_changes()$`Common.Words`, color='#86B4E6')
    plot2
  })
  
  output$business2 <- renderHighchart({
    plot2 <- highchart() %>% 
      hc_chart(type = "column") %>% 
      #hc_yAxis(title = list(text = "Weights")) %>% 
      hc_plotOptions(column = list(stacking = "normal")) %>%
      hc_xAxis(categories = business_changes()$Year) %>% 
      hc_yAxis(max = 1) %>%
      hc_add_series(name="Deleted.Words", data=business_changes()$`Deleted.Words`, color='#444349') %>%
      hc_add_series(name="New.Words", data=business_changes()$`New.Words`, color='#A4EA8A') %>%
      hc_add_series(name="Common.Words", data=business_changes()$`Common.Words`, color='#86B4E6')
    plot2
  })  
  
  output$heatmap_risk <- renderHighchart({
    heatmap <- highchart() %>%
      hc_chart(type = "heatmap")
      #hc_title(text = "Simulated values by years and months") %>%
      #hc_xAxis(categories = data$Company.Name) %>%
    if(input$heat.type == 'Jaccard') {
      heatmap <- heatmap %>%
        hc_add_series(name = "Jaccard", data = list_parse2(filled_risk[,c('Year','Id','Jaccard')]))
    } else if(input$heat.type == 'TF-IDF') {
      heatmap <- heatmap %>%
        hc_add_series(name = "TF-IDF", data = list_parse2(filled_risk[,c('Year','Id','TF-IDF')]))
    } else if (input$heat.type == 'Word2Vec') {
      heatmap <- heatmap %>%
        hc_add_series(name = "Word2Vec", data = list_parse2(filled_risk[,c('Year','Id','Word2Vec')]))
    }
    heatmap <- heatmap %>%
      hc_yAxis(categories = c('', names(mapping_risk))) %>%
      hc_colorAxis(minColor = "#ffd3b6", maxColor = "#ff8b94")
    heatmap
  })
  
  output$heatmap_business <- renderHighchart({
    heatmap <- highchart() %>%
      hc_chart(type = "heatmap")
    #hc_title(text = "Simulated values by years and months") %>%
    #hc_xAxis(categories = data$Company.Name) %>%
    if(input$heat.type == 'Jaccard') {
      heatmap <- heatmap %>%
        hc_add_series(name = "Jaccard", data = list_parse2(filled_business[,c('Year','Id','Jaccard')]))
    } else if(input$heat.type == 'TF-IDF') {
      heatmap <- heatmap %>%
        hc_add_series(name = "TF-IDF", data = list_parse2(filled_business[,c('Year','Id','TF-IDF')]))
    } else if (input$heat.type == 'Word2Vec') {
      heatmap <- heatmap %>%
        hc_add_series(name = "Word2Vec", data = list_parse2(filled_business[,c('Year','Id','Word2Vec')]))
    }
    heatmap <- heatmap %>%
      hc_yAxis(categories = c('', names(mapping_business))) %>%
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
    DT::datatable(risk_dataset()[,c('CIK', 'Year','Jaccard', 'TF-IDF', 'Word2Vec','Total.Words','Deleted.Words','New.Words', 'Top.Words')],
                  rownames = F, options = list(bFilter=0))
  )

  output$tab2 <- DT::renderDataTable(
    DT::datatable(business_dataset()[,c('CIK', 'Year','Jaccard', 'TF-IDF', 'Word2Vec','Total.Words','Deleted.Words','New.Words', 'Top.Words')],
                  rownames = F, options = list(bFilter=0, bLengthChange=0))
  )
  
  output$tab3 <- DT::renderDataTable(
    DT::datatable(cik_map, rownames = F)
  )
  
  output$tit1 <- renderText(
    risk_dataset()[risk_dataset()$CIK == values$company, 'Company.Name'][1]
  )
  
  output$tit2 <- renderText(
    business_dataset()[business_dataset()$CIK == values$company, 'Company.Name'][1]
  )
  
  ## Send plots to UI.
  #plot2 %>% bind_shiny("word_dist")
})

