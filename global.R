library(shiny)
library(DT)
library(dplyr)
library(readr)
library(plotly)
library(ggplot2)
library(fresh)
library(shinyWidgets)

source("R/data_loading.R")
source("R/styling.R")
source("R/utils.R")

# Load data
drug_data <- load_drug_data()
unique_drugs <- sort(unique(c(drug_data$Drug_A, drug_data$Drug_B)))