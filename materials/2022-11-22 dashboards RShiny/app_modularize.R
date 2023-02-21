library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Shiny Demo"),

    # Sidebar with a slider input for number of bins 
    sliderInput(inputId = "num",
      label = "Choose a number:",
      min = 1,
      max = 100,
      value = 25),
    plotOutput("hist"),
    verbatimTextOutput("stats")
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  data <- reactive({
    rnorm(input$num)
  })
  output$hist <- renderPlot({
    hist(data())
  })
  output$stats <- renderPrint({
    summary(data())
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
