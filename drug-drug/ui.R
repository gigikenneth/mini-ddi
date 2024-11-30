# ui.R
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  
  div(class = "material-card",
      style = "background-color: var(--md-sys-color-primary-container); margin-top: 24px;",
      h1(class = "title-large", style = "color: var(--md-sys-color-on-primary-container);", 
         "Drug Interaction Checker")
  ),
  
  fluidRow(
    column(4,
           div(class = "material-card",
               selectizeInput("drug1", 
                              "Select First Drug", 
                              choices = unique_drugs,
                              options = list(
                                placeholder = 'Type to search...',
                                onInitialize = I('function() { this.setValue(""); }')
                              )),
               selectizeInput("drug2", 
                              "Select Second Drug", 
                              choices = unique_drugs,
                              options = list(
                                placeholder = 'Type to search...',
                                onInitialize = I('function() { this.setValue(""); }')
                              )),
               actionButton("check", "Check Interaction", 
                            class = "material-button btn-block")
           ),
           
           # Statistics Cards
           div(class = "material-card",
               h3("Database Statistics", class = "title-large"),
               fluidRow(
                 column(4, 
                        div(class = "stats-value", 
                            HTML(paste("📊", textOutput("total_drugs", inline = TRUE)))),
                        div(class = "stats-label", "Unique Drugs")
                 ),
                 column(4,
                        div(class = "stats-value", 
                            HTML(paste("🔄", textOutput("total_interactions", inline = TRUE)))),
                        div(class = "stats-label", "Known Interactions")
                 ),
                 column(4,
                        div(class = "stats-value", 
                            HTML(paste("⚠️", textOutput("major_interactions", inline = TRUE)))),
                        div(class = "stats-label", "Major Risks")
                 )
               ),
               
               # Add disclaimer with styled box
               div(class = "disclaimer-box",
                   HTML("⚕️ <em>Disclaimer: This tool is for educational purposes only. Always consult healthcare professionals for medical advice.</em>")
               )
           ),
           
           # Severity Legend
           div(class = "material-card",
               h3("Severity Levels", class = "title-large"),
               div(class = "severity-chip severity-major", "Major"),
               div(class = "severity-chip severity-moderate", "Moderate"),
               div(class = "severity-chip severity-minor", "Minor"),
               div(class = "severity-chip severity-unknown", "Unknown")
           )
    ),
    
    column(8,
           # Results Panel
           conditionalPanel(
             condition = "input.check > 0",
             div(class = "material-card",
                 h3("Interaction Results", class = "title-large"),
                 uiOutput("interaction_result"),
                 DTOutput("interaction_table")
             )
           ),
           
           # Visualizations
           div(class = "material-card",
               h3("Interaction Analysis", class = "title-large"),
               fluidRow(
                 column(6, plotlyOutput("severity_pie")),
                 column(6, plotlyOutput("top_drugs_bar"))
               )
           ),
           
           # Recent Interactions
           div(class = "material-card",
               h3("Recent Interactions", class = "title-large"),
               DTOutput("all_interactions")
           )
    )
  )
)