library(shiny)
library(dplyr)
library(tidyr)
library(reshape)
library(stringr)
library(shinyFiles)
library(broom)
library(zoo)   


setwd('/home/hs2865/src/f16-GS/capstone_app')
data <- read.csv("results.csv")
colnames(data) <- c('CIK', 'Jaccard', 'TF-IDF', 'Deleted Words','New Words', 'Top Words', 'Year')
data[,c(2,3,4,5)] = round(data[,c(2,3,4,5)],2)
companies = read.csv('company_list.csv', stringsAsFactors = F)

data <- merge(x = data, y = companies[,c('CIK', 'Company.Name')], by = "CIK", all.x = TRUE)



function(input, output) {
  
  # Fill in the spot we created for a plot
  dataset <- eventReactive(input$go, {
    
    data[data$CIK == input$cik,]
  })
                           
                           
                           
  output$plot1 <- renderPlot({
    tf.frame = data.frame(Measure = 'TF-IDF', value = dataset()$`TF-IDF`, Year = dataset()$Year)
    jac.frame = data.frame(Measure = 'Jaccard', value = dataset()$Jaccard, Year = dataset()$Year)
    distance = rbind(tf.frame, jac.frame)
    
    ggplot(data=distance, aes(x=Year, y=value, fill=Measure)) + 
      geom_bar(colour="black", stat="identity",
               position=position_dodge(),
               width = .5, size=.3) +                        # Thinner lines
      scale_fill_manual(values=c("#31a354", "#2c7fb8"), name = "Measures: \n") +
      xlab("Years") + ylab("Cosine & Jaccard distance") + # Set axis labels
      theme_bw() + ylim(0,1) +
      theme(
        #plot.background = element_blank()
        #panel.grid.major = element_blank()
        panel.grid.minor = element_blank()
        ,panel.border = element_blank(),
        axis.line.x = element_line(color="black", size = .5),
        axis.line.y = element_line(color="black", size = .5),
        axis.text=element_text(size=12),
        axis.title=element_text(size=14),
        legend.text=element_text(size=14),
        legend.title = element_text(size = 16, face = 'bold')
      ) + scale_x_continuous(breaks = dataset()$Year)    
  })
  
  
  output$plot2 <- renderPlot({
    tf.frame = data.frame(Measure = 'New Words', value = dataset()$`New Words`, Year = dataset()$Year)
    jac.frame = data.frame(Measure = 'Deleted Words', value = dataset()$`Deleted Words`, Year = dataset()$Year)
    distance = rbind(tf.frame, jac.frame)
    
    ggplot(data=distance, aes(x=Year, y=value, fill=Measure, label = value)) + 
      geom_bar(colour="black", stat="identity",
               width = .5, size=.3) +  
      geom_text(size = 4, position = position_stack(vjust = 0.5), col = 'white') + 
      scale_fill_manual(values=c("#31a354", "#2c7fb8"), name = "Measures: \n") +
      xlab("Years") + ylab("Share") + # Set axis labels
      theme_bw() + ylim(0,1) +
      theme(
        #plot.background = element_blank()
        #panel.grid.major = element_blank()
        panel.grid.minor = element_blank()
        ,panel.border = element_blank(),
        axis.line.x = element_line(color="black", size = .5),
        axis.line.y = element_line(color="black", size = .5),
        axis.text=element_text(size=12),
        axis.title=element_text(size=14),
        legend.text=element_text(size=14),
        legend.title = element_text(size = 16, face = 'bold')
      ) + scale_x_continuous(breaks = dataset()$Year)    
  })
  
  output$tab1 <- DT::renderDataTable(
    DT::datatable(dataset()[,c('CIK', 'Year','Jaccard', 'TF-IDF', 'Deleted Words','New Words', 'Top Words')])
  )

  output$tab2 <- DT::renderDataTable(
    DT::datatable(data[,c('CIK', 'Year','Jaccard', 'TF-IDF', 'Deleted Words','New Words', 'Top Words')])
  )
  
  output$tit <- renderText(
    dataset()[dataset()$CIK == input$cik, 'Company.Name'][1]
  )
  
  

  
}
