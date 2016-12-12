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
      menuItem("Overview", tabName = "overview", icon = icon("book")),
      menuItem("Analysis", tabName = "analysis", icon = icon("bar-chart")),
      menuItem("Heatmap", tabName = "heatmap", icon = icon("table"))
    ),
    ## Filtering items.
    textInput('cik', "Enter CIK", '0000005981'),
    actionButton('go', 'Go!')
  ),
  
  dashboardBody(
    tabItems(    
      tabItem(tabName = 'overview',
              h1('Quantifying Changes in Financial Reports'),
              fluidRow(
                column(10,
                        p('The United States Securities and Exchange Commission (SEC) requires that companies
                          with more than $10MM in assets and more than 500 owners of a class of equity securities
                          must file annual and quarterly reports that provide a comprehensive summary of their financial performance.
                          These annual reports are known as Form 10-K and Form 10-Q respectively. Information in Form 10-K includes,
                          but is not limited to, company history, organizational structure, executive compensation, risk factors
                          and auditedfinancial statements. Form 10-Q contains similar, though less detailed, information.
                          Most notably financial statements in the 10-Q are typically unaudited. Firms rarely make significant changes
                          to the language and construction of their 10-Ks and 10-Qs; usually they simply repeat the information
                          and language used to convey such information from one report to the next.
                          Only a small percentage of companies make large changes to their reports on a quarterly or annual basis.
                          Given this tendency, when a firm does break with their reporting routine, it may signal important information
                          about future financial performance.'),
                       p(' .'),
                       p(' .')
                       ),
                fluidRow(
                  column(6,
                       DT::dataTableOutput('tab3')
                       )
                )
                )
              ),
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
        tabItem(tabName = 'heatmap',
                h2('Overview of All Companies'),
                radioButtons("map.type", label = p("Measure"),  inline=TRUE, 
                             choices = list("Jaccard" = "Jaccard", "TF-IDF" = "TF-IDF", "Word2Vec" = "Word2Vec"),
                             selected = "TF-IDF"),
                fluidRow(
                  column(6,
                         highchartOutput("heatmap",height = "800px")
                  ),
                  column(6,
                         highchartOutput("heatmap2",height = "800px")
                  )
                )
              )
      )
  )
)
