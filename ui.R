##################
# User Interface #
##################

ui <- dashboardPage(
  dashboardHeader(title = tags$b("IoCAT")),   
  
  dashboardSidebar(
  
    tabItem(
      tabName = "upload",
      h3("Template file"),
      downloadButton("download_template", "Download the template"),
      tags$hr()
    ),
    
    tabItem(
      tabName = "load",
      h3("Upload a completed template file"),
      fileInput(
        "file",
        "Select the file",
        accept = c(".xlsx", ".xls", ".csv")
      ),
      
      tags$hr(),
      helpText("Select file to display the data."),
      uiOutput("file_info")
    )
  ),
  
  
  dashboardBody(
    
    # -------------------------
    # 1st row
    # -------------------------
    
    fluidRow(
      box(
        title = "Patient information",
        status = "primary",
        solidHeader = TRUE,
        
        fluidRow(
          column(6,
                 strong("Identification: "), textOutput("patient", inline = TRUE), br(),
                 strong("Age: "), textOutput("age", inline = TRUE), br(),
                 strong("Weight: "), textOutput("weight", inline = TRUE), br(),
                 strong("Height: "), textOutput("height", inline = TRUE), br(),
                 strong("Body surface area: "), textOutput("bsa", inline = TRUE), br(),
                 strong("Body mass index: "), textOutput("bmi", inline = TRUE), br(),
                 strong("Injected dose: "), textOutput("dose", inline = TRUE)
          ),
          column(6,
                 div(
                   style = "border: 2px solid red; padding: 10px; border-radius: 5px;",
                   strong("Measured GFR (Brochner-Mortenson)"), br(), br(),
                   strong("Raw: "), textOutput("gfr1", inline = TRUE), br(),
                   strong("Corrected: "), textOutput("gfr2", inline = TRUE)
                 )
          )
        )
      ),
      
      box(
        title = "Reference values",
        status = "primary",
        solidHeader = TRUE,
        
        fluidRow(
          column(12,
                 uiOutput("source", inline = TRUE)
          )
        )
      ),
      
    ),

    
    # -------------------------
    # 2nd row
    # -------------------------
    
    fluidRow(
      box(
        title = "Linear regression",
        status = "primary",
        solidHeader = TRUE,
        radioButtons(
          inputId = "Presentation",
          label = "Choose Graph:",
          choices = c("Regression" = "reg",
                      "Residuals"  = "res"),
          selected = "reg",
          inline = TRUE
        ),
        plotOutput("plot1", height = "300px")
      ),
      
      box(
        title = "GFR values",
        status = "primary",
        solidHeader = TRUE,
        radioButtons(
          inputId = "methode",
          label = "Choose reference:",
          choices = c("1" = "abm",
                      "2" = "fenton",
                      "3" = "astley"
          ),
          selected = "abm",
          inline = TRUE
        ),
        plotOutput("plot2", height = "300px")
      )
    ),
    
    
    # -------------------------
    # 3rd row
    # -------------------------
   
    fluidRow(
      box(
        title = "Graph export",
        #width = 8,
        fluidRow(
          column(4,
                 selectInput("export_format", "Format file", 
                             choices = c("PNG", "TIFF"), 
                             selected = "PNG")
          ),
          column(4,
                 numericInput("export_width", "width (px)", 
                              value = 1000, min = 100)
          ),
          column(4,
                 numericInput("export_height", "height (px)", 
                              value = 850, min = 100)
          )
        ),
        fluidRow(
          column(12,
                 downloadButton("download_plots", "Download graphs")
          )
        )
      ),
      
      box(
        title = "CKD based criteria",
        status = "primary",
        solidHeader = TRUE,
        plotOutput("plot3", height = "115px")
      )
    )
  )
)
