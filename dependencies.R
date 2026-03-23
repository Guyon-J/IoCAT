################
# Dependencies #
################

# Liste des packages nécessaires
required_packages <- c("dplyr",
                       "ggplot2",
                       "openxlsx",
                       "readxl",
                       "shiny",
                       "shinydashboard")


new.packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if (length(new.packages)) {
  install.packages(new.packages)
}

rm(new.packages)

library(dplyr)
library(ggplot2)
library(openxlsx)
library(readxl) 
library(shiny)
library(shinydashboard)