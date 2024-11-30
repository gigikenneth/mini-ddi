# File: R/data_loading.R
load_drug_data <- function() {
  # In production, use this:
  drug_interactions <- read_csv("data/ddinter_downloads_code_A.csv")
  
#   # For development, using the provided data directly
#   drug_interactions <- read.csv(text = "DDInterID_A,Drug_A,DDInterID_B,Drug_B,Level
# DDInter1247,Moxifloxacin,DDInter825,Glimepiride,Major
# [... paste your CSV data here ...]")
  
  return(drug_interactions)
}