# WELCOME to IoCAT: Iohexol Clearance Analysis Tool

# INSTALL DEPENDENCIES ---------------------------------------------------------

source('dependencies.R')
# load all packages
lapply(required_packages, require, character.only = TRUE)


# GLOBAL FUNCTION --------------------------------------------------------------

# -------------------------
# template
# -------------------------

datasheet <- function(filename = "raw_iohexol.xlsx") {
  
  wb <- createWorkbook()
  addWorksheet(wb, "Data")
  
  col_A <- c(
    "Personal information",
    "Last name",
    "First name",
    "Birth date",
    "Date of visit",
    "Gender (W/M)",
    "Weight (kg)",
    "Height (cm)",
    "Estimated GFR (ml/min/1.73m2)",
    "",
    "Iohexol",
    "mg iodine/mL",
    "",
    "Syringe weight",
    "Preinjection (g)",
    "Postinjection (g)",
    "or injected volume (mL)",
    "",
    "Pharmacokinetic data",
    "Time_0",
    paste0("Time_", 1:10)
  )
  
  col_B <- c(
    "", "", "",
    rep("Enter value", 6),
    "",
    "",
    "300",
    "",
    "",
    "Enter value",
    "Enter value",
    "Enter value",
    "",
    "HH:MM",
    "Enter value",
    rep("Enter value", 10)
  )
  
  col_C <- c(
    rep("", 19),
    "",
    paste0("Conc_", 1:10)
  )
  
  col_D <- c(
    rep("", 18),
    "mg/L",
    "",
    rep("Enter value", 10)
  )
  
  stopifnot(length(col_A) == length(col_B),
            length(col_A) == length(col_C),
            length(col_A) == length(col_D))
  
  data <- data.frame(
    A = col_A,
    B = col_B,
    C = col_C,
    D = col_D,
    stringsAsFactors = FALSE
  )
  
  writeData(wb, "Data", data, colNames = FALSE)
  nrows <- nrow(data)
  
  unlocked_style <- createStyle(locked = FALSE)
  addStyle(wb, "Data", unlocked_style, rows = 2:nrows, cols = 2, gridExpand = TRUE)
  addStyle(wb, "Data", unlocked_style, rows = 2:nrows, cols = 4, gridExpand = TRUE)
  
  protectWorksheet(wb, "Data", protect = TRUE, password = NULL)
  
  setColWidths(wb, "Data", cols = 1, widths = 30)
  
  style_blue <- createStyle(fgFill = "#9BC2E6")
  style_green <- createStyle(fgFill = "#C6E0B4")
  style_orange <- createStyle(fgFill = "#FCD5B4")
  style_yellow <- createStyle(fgFill = "#FFF2CC")
  style_yellow_dark <- createStyle(fgFill = "#FFD966", textDecoration = "bold")
  
  style_blue_dark <- createStyle(fgFill = "#2E75B6", fontColour = "#FFFFFF", textDecoration = "bold")
  style_green_dark <- createStyle(fgFill = "#548235", fontColour = "#FFFFFF", textDecoration = "bold")
  style_orange_dark <- createStyle(fgFill = "#C65911", fontColour = "#FFFFFF", textDecoration = "bold")
  
  style_grey_text <- createStyle(fontColour = "gray30")
  
  addStyle(wb, "Data", style_grey_text, rows = 1:nrows, cols = 2, gridExpand = TRUE, stack = TRUE)
  addStyle(wb, "Data", style_grey_text, rows = 1:nrows, cols = 4, gridExpand = TRUE, stack = TRUE)
  
  addStyle(wb, "Data", style_blue, rows = 1:10, cols = 1, gridExpand = TRUE, stack = TRUE)
  addStyle(wb, "Data", style_yellow, rows = 12:13, cols = 1, gridExpand = TRUE, stack = TRUE)
  addStyle(wb, "Data", style_green, rows = 14:18, cols = 1, gridExpand = TRUE, stack = TRUE)
  addStyle(wb, "Data", style_orange, rows = 19:nrows, cols = 1, gridExpand = TRUE, stack = TRUE)
  
  addStyle(wb, "Data", style_blue_dark, rows = 1, cols = 1:4, stack = TRUE)
  addStyle(wb, "Data", style_yellow_dark, rows = 11, cols = 1:4, stack = TRUE)
  addStyle(wb, "Data", style_green_dark, rows = 14, cols = 1:4, stack = TRUE)
  addStyle(wb, "Data", style_orange_dark, rows = 19, cols = 1:4, stack = TRUE)
  
  addStyle(wb, "Data", style_orange, rows = 21:nrows, cols = 3, gridExpand = TRUE, stack = TRUE)
  
  saveWorkbook(wb, filename, overwrite = TRUE)
}


# -------------------------
# data extraction
# -------------------------

extraction <- function(filepath) {
  
  df <- readxl::read_excel(filepath, col_names = FALSE)
  
  empty <- c("", "Enter value", " ", "Enter Name", "Enter date", "Enter ID")
  
  get_val <- function(r, c) {
    val <- df[r, c][[1]]
    if (is.na(val)) return(NA)
    val_clean <- trimws(as.character(val))
    if (val_clean %in% empty) {return(NA)}
    else {return(val)}
  }
  
  res <- list()
  res$last_name       <- get_val(2, 2)
  res$first_name      <- get_val(3, 2)
  res$birth_date      <- get_val(4, 2)
  res$date_of_visit   <- get_val(5, 2)
  res$gender          <- get_val(6, 2)
  res$weight_kg       <- get_val(7, 2)
  res$height_cm       <- get_val(8, 2)
  res$eGFR            <- get_val(9, 2)
  res$iodine_mg_ml    <- get_val(12, 2)
  res$preinjection_g  <- get_val(15, 2)
  res$postinjection_g <- get_val(16, 2)
  res$injected_vol_ml <- get_val(17, 2)
  
  time_0_raw <- get_val(20, 2)
  res$time_0 <- time_0_raw
  
  times_raw <- sapply(21:30, function(r) get_val(r, 2))
  concs_raw <- sapply(21:30, function(r) get_val(r, 4))
  
  t0_min <- as.numeric(time_0_raw) * 1440
  ti_min <- as.numeric(times_raw) * 1440
  
  delta_minutes <- ti_min - t0_min
  ln_concs <- log(as.numeric(concs_raw))
  
  df_plot <- data.frame(
    Point      = paste0("T", 1:10),
    Time  = delta_minutes,
    Conc = as.numeric(concs_raw),
    Ln_Conc   = ln_concs
  ) %>%
    na.omit(df_plot)
  
  val <- list()
  val$x_time      <- df_plot$Time
  val$y_raw_conc  <- df_plot$Conc
  val$y_conc      <- df_plot$Ln_Conc
  
  output <- list(
    patient_info = res,
    measurements = df_plot,
    values = val
  )
  
  return(output)
}

caracteristics <- function(filepath) {
  
  df <- extraction(filepath)
  
  date_visit <- as.numeric(df$patient_info$date_of_visit)
  date_birth <- as.numeric(df$patient_info$birth_date)
  age <- round((date_visit - date_birth) / 365.25, digits = 1)
  
  weight <- as.numeric(df$patient_info$weight_kg)
  height <- as.numeric(df$patient_info$height_cm)
  
  bsa <- 0.007184 * weight^0.425 * height^0.725
  bmi <- weight / (height/100)^2
  
  output <- list(
    weight = weight,
    height = height,
    age = age,
    bmi = bmi,
    bsa = bsa
  )
  
  return(output)
}


# -------------------------
# Analysis
# -------------------------

regression <- function(filepath) {
  
  df <- extraction(filepath)
  df <- data.frame(Time = df$values$x_time, Conc = df$values$y_conc)
  
  x_range <- range(df$Time); x_margin <- diff(x_range) * 0.2
  y_range <- range(df$Conc); y_margin <- diff(y_range) * 0.2
  
  p1 <- ggplot(df, aes(x = Time, y = Conc)) +
    expand_limits(x = c(x_range[1] - x_margin, x_range[2] + x_margin),
                  y = c(y_range[1] - y_margin, y_range[2] + y_margin)) +
    theme_bw() +
    labs(x = "Sample time (min)", y = "Ln(Iohexol)")
  
  model <- lm(Conc ~ Time, data = df)
  r2 <- summary(model)$r.squared
  coeff <- coef(model)
  
  couleur_r2 <- if (r2 > 0.975) {
    "#27ae60"
  } else if (r2 >= 0.90) {
    "#e67e22"
  } else {
    "#c0392b"
  }
  
  eq_label1 <- paste0("y = ", round(coeff[2], 3), "x + ", round(coeff[1], 3))
  eq_label2 <- paste0("R² = ", round(r2, 3))
  
  p1 <- p1 +
    geom_smooth(method = "lm", se = FALSE, color = couleur_r2, linetype = "dashed", linewidth = 1.5) +
    geom_point(size = 6, color = "#2c3e50") +
    annotate("label", x = Inf, y = Inf, label = eq_label1,
             hjust = 1.1, vjust = 1.5, size = 5,
             color = "black", fill = "white", fontface = "bold") +
    annotate("label", x = Inf, y = Inf, label = eq_label2,
             hjust = 1.17, vjust = 2.6, size = 5,
             color = "white", fill = couleur_r2, fontface = "bold") +
    theme(
      legend.position = "none",
      axis.title = element_text(size = 14),
      axis.text  = element_text(size = 14)
    )
  
  intercept <- coef(model)[1]
  c0 <- exp(intercept)
  slope <- coef(model)[2]
  ke <- abs(slope)
  
  results <- list()
  results$auc          <- c0 / ke
  results$half_life    <- log(2) / ke
  
  df$residus <- rstandard(model)
  df$Point <- paste0("T", 1:nrow(df))
  
  p2 <- ggplot(df, aes(x = Point, y = residus)) +
    geom_hline(yintercept = c(-2, 2), linetype = "dashed", color = "darkred") +
    geom_bar(stat = "identity", aes(fill = abs(residus) > 2)) +
    scale_fill_manual(values = c("#2c3e50", "firebrick")) +
    labs(
      y = "Residus", x = "Sample point") +
    theme_bw() +
    theme(
      legend.position = "none",
      axis.title = element_text(size = 14),
      axis.text  = element_text(size = 14)
    )
  
  # Final
  output <- list(
    graph1 = p1,
    graph2 = p2,
    results = results
  )
  
  return(output)
}


clearance <- function(filepath) {
  
  df1 <- extraction(filepath)
  form    <- as.numeric(df1$patient_info$iodine_mg_ml)
  inj_1   <- as.numeric(df1$patient_info$preinjection_g)
  inj_2   <- as.numeric(df1$patient_info$postinjection_g)
  inj_vol <- as.numeric(df1$patient_info$injected_vol_ml)
  
  df2 <- regression(filepath)
  auc <- as.numeric(df2$results$auc)
  
  df3 <- caracteristics(filepath)
  bsa <- as.numeric(df3$bsa)

  dose <- NA
  
  if (!is.na(inj_vol)) {
    dose_ml <- inj_vol * 1000
    if (form == 300) {
      dose <- dose_ml * 647
    } else if (form == 140) {
      dose <- dose_ml * 302
    } else if (form == 180) {
      dose <- dose_ml * 388
    } else if (form == 240) {
      dose <- dose_ml * 518
    } else if (form == 350) {
      dose <- dose_ml * 755
    }
  } else if (!is.na(inj_1) && !is.na(inj_2)) {
    diff <- (inj_1 - inj_2) * 1000
    if (form == 300) {
      dose <- diff * 647 / 1.349
    } else if (form == 140) {
      dose <- diff * 302 / 1.164
    } else if (form == 180) {
      dose <- diff * 388 / 1.280
    } else if (form == 350) {
      dose <- diff * 755 / 1.406
    }
  } 
  
  if (is.na(dose) || is.na(auc) || auc == 0) {
    return(list(
      dose = NA,
      clearance = NA,
      bm = NA,
      gfr = NA
    ))
  }

  clearance <- dose / auc
  bm <- (clearance * 0.990778) - (0.001218 * clearance^2)
  gfr <- bm / bsa * 1.73
  
  return(list(
    dose = dose,
    clearance = clearance,
    bm = bm,
    gfr = gfr
  ))
}



# -------------------------
# Graphs
# -------------------------

ref_plot <- function(method = c("abm", "fenton", "astley"), filepath) {
  
  method <- match.arg(method)
  carac <- caracteristics(filepath)
  age   <- carac$age
  
  df_clear <- clearance(filepath)
  gfr      <- df_clear$gfr
  
  df1    <- extraction(filepath)
  gender <- df1$patient_info$gender
  eGFR <- df1$patient_info$eGFR
  eGFR <- as.numeric(eGFR)
  
  ref_data <- switch(method,
                     
                     "fenton" = {
                       ref_fenton <- data.frame(
                         Gender = c(rep("M", 14), rep("W", 14)),
                         Old = rep(c(20, 29, 30, 34, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80), 2),
                         lower_ = c(
                           74, 74, 74, 74, 73, 70, 67, 63, 60, 57, 53, 50, 47, 43,   # M
                           72, 72, 72, 72, 72, 68, 64, 60, 56, 52, 48, 44, 40, 36    # W
                         ),
                         mean_ = c(
                           100, 100, 100, 100, 100, 96, 93, 90, 86, 83, 80, 77, 73, 70,
                           99, 99, 99, 99, 99, 95, 91, 87, 83, 79, 75, 71, 67, 63
                         ),
                         upper_ = c(
                           127, 127, 127, 127, 126, 123, 119, 116, 113, 110, 106, 103, 100, 97,
                           125, 125, 125, 125, 125, 121, 117, 114, 110, 106, 102, 98, 94, 90
                         ),
                         threshold_ = c(
                           90, 90, 80, 80, 80, 80, 80, 80, 80, 76, 71, 67, 63, 58,
                           90, 90, 80, 80, 80, 80, 80, 80, 75, 70, 64, 59, 54, 49
                         )
                       )
                       
                       df_plot <- subset(ref_fenton, Gender == gender)
                       
                       p <- ggplot(df_plot, aes(x = Old)) +
                         geom_line(aes(y = mean_), color = "#2c3e50", linewidth = 1.5) +
                         geom_line(aes(y = lower_),  color = "steelblue", linetype = "dashed", linewidth = 1) +
                         geom_line(aes(y = upper_), color = "steelblue", linetype = "dashed", linewidth = 1) +
                         geom_line(aes(y = threshold_), color = "violetred3", linetype = "twodash", linewidth = 1) +
                         annotate("point", x = age, y = gfr, 
                                  size = 6, shape = 21, 
                                  color = "white", fill = "darkred", alpha = 0.8) 
                     },
                     
                     "astley" = {
                       ref_astley <- data.frame(
                         Gender = c(rep("M", 17), rep("W", 17)),
                         Old = rep(c(20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100), 2),
                         p5 = c(
                           78,81,81,81,80,76,72,69,66,63,58,53,49,44,39,34,29,
                           81,83,82,82,81,76,72,68,65,61,56,51,46,40,35,29,25
                         ),
                         p50 = c(
                           99,101,101,101,100,95,90,86,82,79,75,71,66,62,58,55,52,
                           101,102,102,102,100,95,90,85,81,77,72,68,63,59,55,50,47
                         ),
                         p95 = c(
                           119,120,121,121,119,113,108,103,99,94,91,88,84,81,78,76,74,
                           121,122,122,122,120,114,108,103,98,93,89,85,81,78,74,72,69
                         )
                       )
                       
                       df_plot <- subset(ref_astley, Gender == gender)
                       
                       p <- ggplot(df_plot, aes(x = Old)) +
                         geom_line(aes(y = p50), color = "#2c3e50", linewidth = 1.5) +
                         geom_line(aes(y = p5),  color = "steelblue", linetype = "dashed", linewidth = 1) +
                         geom_line(aes(y = p95), color = "steelblue", linetype = "dashed", linewidth = 1) +
                         annotate("point", x = age, y = gfr, 
                                  size = 6, shape = 21, 
                                  color = "white", fill = "darkred", alpha = 0.8)
                     },
                     
                     "abm" = {
                       ref_abm <- data.frame(
                         Old = c(18, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95),
                         p5  = c(82, 82, 82, 82, 82, 82, 78, 74, 69, 65, 60, 56, 52, 47, 43, 38, 34),
                         p10 = c(88, 88, 88, 88, 88, 88, 83, 79, 74, 70, 66, 61, 57, 52, 48, 44, 39),
                         p50 = c(106, 106, 106, 106, 106, 106, 102, 97, 93, 89, 84, 80, 75, 71, 67, 62, 58),
                         p90 = c(125, 125, 125, 125, 125, 125, 120, 116, 112, 107, 103, 98, 94, 90, 85, 81, 76),
                         p95 = c(130, 130, 130, 130, 130, 130, 126, 121, 117, 112, 108, 104, 99, 95, 90, 86, 82)
                       )
                       
                       p <- ggplot(ref_abm, aes(x = Old)) +
                         geom_line(aes(y = p50), color = "#2c3e50", linewidth = 1.5) +
                         geom_line(aes(y = p5),  color = "steelblue", linetype = "dashed", linewidth = 1) +
                         geom_line(aes(y = p95), color = "steelblue", linetype = "dashed", linewidth = 1) +
                         geom_line(aes(y = p10), color = "violetred3", linetype = "twodash", linewidth = 1) +
                         geom_line(aes(y = p90), color = "skyblue4", linetype = "dotted", linewidth = 1) +
                         annotate("point", x = age, y = gfr, 
                                  size = 6, shape = 21, 
                                  color = "white", fill = "darkred", alpha = 0.8)
                     },
  )
  
  p <- p +
    theme_bw() +
    theme(
      legend.position = "none",
      axis.title = element_text(size = 14),
      axis.text  = element_text(size = 14)
    ) +
    scale_y_continuous(limits = c(0, 150), breaks = seq(0, 150, 25)) +
    scale_x_continuous(limits = c(15, 100), breaks = seq(20, 100, 10)) +
    labs(x = "Age", y = "GFR (mL/min/1.73m²)") +
    
    annotate("point", x = age, y = eGFR,
             size = 6, shape = 21, 
             color = "white", fill = "darkblue", alpha = 0.8) +
    annotate("rect", xmin = 80, xmax = 95, 
             ymin = 125, ymax = 150, 
             fill = "white", color = "grey80") +
    annotate("point", x = 82, y = 143, 
             size = 5, shape = 21, 
             color = "white", fill = "darkred") +
    annotate("text", x = 84, y = 143, label = "mGFR", hjust = 0, size = 5) +
    annotate("point", x = 82, y = 132, 
             size = 5, shape = 21, 
             color = "white", fill = "darkblue") + 
    annotate("text", x = 84, y = 132, label = "eGFR", hjust = 0, size = 5)

  return(p)
}


ref_val <- function(filepath){
  
  df_clear <- clearance(filepath)
  gfr      <- df_clear$gfr
  
  df1    <- extraction(filepath)
  eGFR <- df1$patient_info$eGFR
  eGFR <- as.numeric(eGFR)
  
  gfr_comment <- if (gfr >= 90) {
    "Normal or high"
  } else if (gfr >= 60) {
    "Mildly decreased (relative to young adult level)"
  } else if (gfr >= 45) {
    "Mildly to moderately decreased"
  } else if (gfr >= 30) {
    "Moderately to severely decreased"
  } else if (gfr >= 15) {
    "Severely decreased"
  } else {
    "Kidney failure"
  }
  
  zones <- data.frame(
    xmin = c(90,60,45,30,15,0),
    xmax = c(120,90,60,45,30,15),
    stage = c("G1","G2","G3a","G3b","G4","G5"),
    color = c("#228B22","#ADFF2F","#FFD700","#FF8C00","#FF0000","#8B0000")
  )
  
  p <- ggplot() +
    geom_rect(data = zones,
              aes(xmin = xmin, xmax = xmax,
                  ymin = 0.9, ymax = 1.1,
                  fill = stage),
              alpha = 0.7) +
    geom_text(data = zones,
              aes(x = (xmin+xmax)/2, y = 1, label = stage),
              fontface = "bold",
              color = "white", size = 4) +
    geom_point(aes(x = gfr, y = 1),
               size = 5, shape = 21, 
               color = "white", fill = "darkred", alpha = 0.8) +
    geom_point(aes(x = eGFR, y = 1),
               size = 5, shape = 21, 
               color = "white", fill = "darkblue", alpha = 0.8) +
    scale_fill_manual(values = setNames(zones$color, zones$stage)) +
    scale_x_reverse(
      limits = c(120,0),
      breaks = c(120,90,60,45,30,15,0)
    ) +
    
    labs(
      title = paste(gfr_comment),
      x = "ml/min/1.73m²",
      y = NULL
    ) +
    theme_minimal() +
    theme(
      legend.position = "none",
      axis.title = element_text(size = 14),
      axis.text  = element_text(size = 14),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid = element_blank(),
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5)
    )
  
  return(p)
}
