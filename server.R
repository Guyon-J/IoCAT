##########
# Server #
##########

server <- function(input, output, session) {

  #########################
  # downloadable template
  #########################
  output$download_template <- downloadHandler(
    filename = function() {
      "raw_iohexol.xlsx"
    },
    content = function(file) {
      datasheet(file)
    }
  )

  data <- reactive({
    req(input$file)
    ext <- tools::file_ext(input$file$name)
    if (ext %in% c("xlsx", "xls")) {
      readxl::read_excel(input$file$datapath)
    } else if (ext == "csv") {
      read.csv(input$file$datapath, sep = ",", header = TRUE)
    } else {
      validate("Format not supported")
    }
  })

  
  #########################
  # Personal information
  #########################
  output$patient <- renderText({
    req(input$file)
    carac <- extraction(input$file$datapath)
    last  <- as.character(carac$patient_info$last_name)
    first <- as.character(carac$patient_info$first_name)
    paste0(last, " ", first)
  })

  output$age <- renderText({
    req(input$file)
    carac <- caracteristics(input$file$datapath)
    age   <- as.numeric(carac$age)
    paste0(round(age, 1), " year")
  })

  output$height <- renderText({
    req(input$file)
    carac <- caracteristics(input$file$datapath)
    height   <- carac$height
    paste0(height, " cm")
  })

  output$weight <- renderText({
    req(input$file)
    carac <- caracteristics(input$file$datapath)
    weight   <- carac$weight
    paste0(weight, " kg")
  })

  output$bsa <- renderText({
    req(input$file)
    carac <- caracteristics(input$file$datapath)
    bsa   <- as.numeric(carac$bsa)
    paste0(round(bsa, 2), " m²")
  })

  output$bmi <- renderText({
    req(input$file)
    carac <- caracteristics(input$file$datapath)
    bmi   <- as.numeric(carac$bmi)
    paste0(round(bmi, 1), " kg/m²")
  })
  
  output$dose <- renderText({
    req(input$file)
    carac <- clearance(input$file$datapath)
    dose   <- carac$dose/1000
    paste0(round(dose, 3), " mg")
  })

  output$gfr1 <- renderText({
    req(input$file)
    carac <- clearance(input$file$datapath)
    bm   <- carac$bm
    paste0(round(bm, 1), " ml/min")
  })

  output$gfr2 <- renderText({
    req(input$file)
    carac <- clearance(input$file$datapath)
    gfr   <- carac$gfr
    paste0(round(gfr, 1), " mL/min/1.73m²")
  })

  output$source <- renderUI({
    req(input$methode)
    if (input$methode == "abm") {
      tagList(
        tags$strong("Percentiles of mGFR (ml/min/1.73 m²) in a population of living donors in France and Switzerland."),
        tags$br(),
        tags$br(),
        tags$strong("Source: "),
        "Recommandations DV Rein. ",
        tags$em("Agence de la biomédecine. "),
        tags$strong("14 décembre 2023"),
        tags$br(),
        tags$strong("URL:"),
        tags$a(
          href = "https://agence-biomedecine.fr/fr/don-et-greffe-d-organes-et-de-tissus/recommandations-dv-rein-synthese-finale-(14-decembre-2023)",
          "agence-biomedecine.fr",
          target = "_blank"
        ),
        tags$br(),
        tags$em("The fuchsia double-dash line corresponds to the 10th percentile",
                style = "color: #CD226B;")
      )
    } else if (input$methode == "fenton") {
      tagList(
        tags$strong("Mean mGFR from 2974 living kidney donors by sex (plasma clearance of an external tracer using the slope and intercept method with Brochner-Mortensen correction)"),
        tags$br(),
        tags$br(),
        tags$strong("Source: "),
        "Fenton A, Montgomery E, Nightinale P et al., Glomerular filtration rate: new age- and gender- specific reference ranges and thresholds for living kidney donation.",
        tags$em(" BMC Nephrology "),
        tags$strong("2018"),
        tags$br(),
        tags$strong("DOI:"),
        tags$a(
          href = "https://doi.org/10.1186/s12882-018-1126-8",
          "10.1186/s12882-018-1126-8",
          target = "_blank"
        ),
        tags$br(),
        tags$em("The fuchsia double-dash line corresponds to the DFG levels considered acceptable by the British Transplantation Society",
                style = "color: #CD226B;")
      )
    } else if (input$methode == "astley") {
      tagList(
        tags$strong("Median eGFR in European healthy individuals by sex (CKD-EPI equation)"),
        tags$br(),
        tags$br(),
        tags$strong("Source: "),
        "Astley ME, Chesnaye NC, Hallan S, et al., Age- and sex-specific reference values of estimated glomerular filtration rate for European adults.",
        tags$em(" Kidney Int. "),
        tags$strong("2025"),
        tags$br(),
        tags$strong("DOI:"),
        tags$a(
          href = "https://doi.org/10.1016/j.kint.2025.02.025",
          "10.1016/j.kint.2025.02.025",
          target = "_blank"
        )
      )
    } 
  })

  
  #########################
  # Graphs
  #########################
  output$plot1 <- renderPlot({
    if (input$Presentation == "reg") {
      req(input$file)
      df <- regression(input$file$datapath)
      df$graph1
    } else if (input$Presentation == "res") {
      req(input$file)
      df <- regression(input$file$datapath)
      df$graph2
    }
  })

  output$plot2 <- renderPlot({ 
    req(input$file)
    df <- ref_plot(method = input$methode, input$file$datapath)
    df
  })

  output$plot3 <- renderPlot({
    req(input$file)
    df <- ref_val(input$file$datapath)
    df
  })

  
  #########################
  # Export data
  #########################
  output$download_plots <- downloadHandler(
    filename = function() {
      ext <- tolower(input$export_format)
      paste0("graphs.", ext)
    },
    content = function(file) {
      width  <- input$export_width
      height <- input$export_height
      if (input$export_format == "PNG") {
        png(file, 
            width = width*2, 
            height = height*2, 
            units = "px", 
            res = 100)
      } else if (input$export_format == "TIF") {
        tiff(file, 
             width = width*2, 
             height = height*2, 
             units = "px", 
             res = 100,
             compression = "zip")
      }
      req(input$file)

      # -------------------------
      # Personal information
      # -------------------------

      df_raw  <- extraction(input$file$datapath)
      carac   <- caracteristics(input$file$datapath)
      clear   <- clearance(input$file$datapath)
      patient <- paste0(df_raw$patient_info$last_name, " ",
                        df_raw$patient_info$first_name)
      
      info_text <- paste0(
        "**Patient Information**\n",
        "     Identification: ", patient, "\n",
        "     Age: ", round(carac$age,1), " year\n",
        "     Weight: ", carac$weight, " kg\n",
        "     Height: ", carac$height, " cm\n",
        "     BSA: ", round(carac$bsa,2), " m²\n",
        "     BMI: ", round(carac$bmi,1), " kg/m²\n",
        "     Injected dose: ", round(clear$dose/1000,3), " mg\n\n",
        "**Measured GFR (Brochner-Mortensen)**\n",
        "     Raw: ", round(clear$bm,1), " mL/min\n",
        "     Corrected: ", round(clear$gfr,1), " mL/min/1.73m²"
      )
      
      text_plot <- ggplot() +
        annotate("text", x = 0, y = 1,
                 label = info_text,
                 hjust = 0, vjust = 1,
                 size = 5) +
        xlim(0,1) + ylim(0,1) +
        theme_void()

      # -------------------------
      # Graphs
      # -------------------------
      p1 <- regression(input$file$datapath)$graph1
      p2 <- ref_plot(method = input$methode,
                     filepath = input$file$datapath)
      p3 <- ref_val(input$file$datapath)

      # -------------------------
      # Final assembly
      # -------------------------
      final_plot <- plot_spacer()/ text_plot / (p1 + p2) / plot_spacer() / p3 / plot_spacer() +
        plot_layout(heights = c(1, 4, 3, 0.2, 0.5, 2))
      print(final_plot)
      dev.off()

      t_path <- tempfile(fileext = ".png")
      
      tryCatch({
        ggplot2::ggsave(
          filename = t_path, 
          plot = final_plot, 
          width = input$export_width, 
          height = input$export_height, 
          units = "px", 
          dpi = 72
        )
        
        img <- magick::image_read(t_path)
        
        img_optimized <- magick::image_strip(img)
        
        magick::image_write(img_optimized, path = file)
        
      }, error = function(e) {
        message("Export error: ", e$message)
      }, finally = {
        if (file.exists(t_path)) {
          file.remove(t_path)
        }
      })     
    }
  )
}
