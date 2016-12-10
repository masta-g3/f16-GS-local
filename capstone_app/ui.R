library(shinydashboard)
library(shiny)
#library(rCharts)
#library(rNVD3)
library(highcharter)
library(DT)
options(shiny.maxRequestSize=100*1024^2) 

##################
### Shinny UI ####
##################


dashboardPage(
  skin = "black",
  dashboardHeader(title = 'Changes in 10-K forms'),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Analysis", tabName = "analysis", icon = icon("bar-chart")),
      menuItem("All Data", tabName = "allData", icon = icon("table"))
    ),
    ## Filtering items.
    textInput('cik', "Enter CIK", '37996'),
    actionButton('go', 'Go!')
  ),
  
  dashboardBody(
    tabItems(    
      tabItem(tabName = "analysis",
                h1(strong(textOutput('tit'))),
                ## Tab Item 1: Charts.
                fluidRow(
                  column(6,
                         #h2(strong("Lexical Changes")),
                         h2("Measures of Change"),
                         #showOutput("plot1","nvd3"),
                         highchartOutput("plot1",height = "400px"),
                         #plotOutput("plot1"),
                         h4('The graph above shows the Jaccard distance and the cosine distance computed
                            using the TF-IDF features of each document. We are basically trying to
                            capture the lexical changes between documents.')
                         
                  ),
                  column(6,
                         #h2(strong("New vs Deleted Words")),
                         h2("Changes in Document Structure"),
                         #showOutput("plot2","nvd3"),
                         highchartOutput("plot2",height = "400px"),
                         #ggvisOutput("word_dist"),
                         h4('The graph above shows the change between documents by decomposing the change in the share
                            of deleted words and new words.')
                  )
                ),
                fluidRow(
                  column(12,
                         h2(strong("Data")),
                         DT::dataTableOutput('tab1')
                  )
                )
                
        ),
        tabItem(tabname = 'allData',
                fluidRow(
                  column(12,
                         h2(strong("All Data")),
                         DT::dataTableOutput('tab2')
                  )
                )
              )
      )
  )
)
