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
      menuItem("Risk Analysis", tabName = "risk", icon = icon("bar-chart")),
      menuItem("Business Analysis", tabName = "business", icon = icon("bar-chart")),
      menuItem("Heatmap", tabName = "heatmap", icon = icon("table")),
      menuItem("Written Report", icon = icon(" fa-file-text-o"), href = "https://github.com/masta-g3/documents/blob/master/FinalCapstoneReport.pdf")
    ),
    ## Filtering items.
    textInput('cik', "Enter CIK", '0001050446'),
    actionButton('go', 'Go!')
  ),
  
  dashboardBody(
    tabItems(    
      tabItem(tabName = 'overview',
              h1('Quantifying Changes in Financial Reports'),
              fluidRow(
                column(11,
                      h4(strong('Introduction')),
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
                      h4(strong('The Tool')),
                      p("The tool presented here aims to tackle this problem, by providing analysts with an easy to use interface
                         track when important changes occur on these documents. The analysts first defines a list of stocks he is
                         interested on (i.e. his investment portfolio), and our model will analyze each of the 10-K documents using a
                         Natural Language Processing framework that is able to quantify the level of lexical and semantic changes occuring
                         on them. The tabs to the left allow the users to explore the data on a company-by-company basis, or to get a general
                         overview of changes on all companies within the portfolio via a heatmap representation. The tool focuses on 2 specific sections
                         from the 10-Ks: 'Risk' and 'Business', given that these are the most relevant to evaluate a company's strategic situation."),
                      h4(strong('Sample Portfolio'))
                     )
              ),
                fluidRow(
                  column(5,
                       DT::dataTableOutput('tab3')
                       ),
                  column(6
                       )
                  ),
                  fluidRow(
                    column(11,
                           p(strong('Capstone Report 2016')),
                           p('Sponsor: Goldman Sachs'),
                           p('Juan Martin Borgnino, Manuel Rueda, Hiroaki Suzuki, Shenghan Yu, Xuyan Xiao')
                       )
                )
              ),
      tabItem(tabName = "risk",
                h1(strong(textOutput('tit1'))),
                ## Tab Item 1: Charts.
                fluidRow(
                  column(6,
                         #h2(strong("Lexical Changes")),
                         h2("Risk - Measures of Change"),
                         #showOutput("plot1","nvd3"),
                         highchartOutput("risk1",height = "400px"),
                         #plotOutput("plot1"),
                         h4('The graph above shows the Jaccard distance and the cosine distance computed
                            using the TF-IDF features of each document, representing lexical similarity.
                            Word2Vec cosine distance is also included to capture semantic changes.')
                         
                  ),
                  column(6,
                         #h2(strong("New vs Deleted Words")),
                         h2("Risk - Changes in Document Structure"),
                         #showOutput("plot2","nvd3"),
                         highchartOutput("risk2",height = "400px"),
                         #ggvisOutput("word_dist"),
                         h4('The graph above shows the change between documents by decomposing the change in the share
                            of deleted words and new words.')
                  )
                ),
                fluidRow(
                  column(12,
                         h2("Risk - Data"),
                         DT::dataTableOutput('tab1')
                  )
                )
                
        ),
      tabItem(tabName = "business",
              h1(strong(textOutput('tit2'))),
              ## Tab Item 1: Charts.
              fluidRow(
                column(6,
                       #h2(strong("Lexical Changes")),
                       h2("Business - Measures of Change"),
                       #showOutput("plot1","nvd3"),
                       highchartOutput("business1",height = "400px"),
                       #plotOutput("plot1"),
                       h4('The graph above shows the Jaccard distance and the cosine distance computed
                          using the TF-IDF features of each document, representing lexical similarity.
                          Word2Vec cosine distance is also included to capture semantic changes.')
                       
                       ),
                column(6,
                       #h2(strong("New vs Deleted Words")),
                       h2("Business - Changes in Document Structure"),
                       #showOutput("plot2","nvd3"),
                       highchartOutput("business2",height = "400px"),
                       #ggvisOutput("word_dist"),
                       h4('The graph above shows the change between documents by decomposing the change in the share
                          of deleted words and new words.')
                       )
                ),
              fluidRow(
                column(12,
                       h2("Business - Data"),
                       DT::dataTableOutput('tab2')
                )
              )
      ),
      tabItem(tabName = 'heatmap',
                fluidRow(
                  radioButtons("heat.type", label = p("Measure"),  inline=TRUE, 
                               choices = list("Jaccard" = "Jaccard", "TF-IDF" = "TF-IDF", "Word2Vec" = "Word2Vec"),
                               selected = "TF-IDF"),
                  column(6,
                         h2('Risk Overview of All Companies'),
                         highchartOutput("heatmap_risk",height = "1600px")
                  ),
                  column(6,
                         h2('Business Overview of All Companies'),
                         highchartOutput("heatmap_business",height = "1600px")
                  )
                )
              )
      )
  )
)
