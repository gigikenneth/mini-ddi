# server.R
server <- function(input, output, session) {
  # Initialize server-side selectize
  updateSelectizeInput(session, 'drug1', choices = unique_drugs, server = TRUE)
  updateSelectizeInput(session, 'drug2', choices = unique_drugs, server = TRUE)
  
  # Statistics outputs
  output$total_drugs <- renderText({
    length(unique_drugs)
  })
  
  output$total_interactions <- renderText({
    nrow(drug_data)
  })
  
  output$major_interactions <- renderText({
    sum(drug_data$Level == "Major")
  })
  
  # Severity distribution pie chart
  output$severity_pie <- renderPlotly({
    severity_counts <- table(drug_data$Level)
    colors <- c(
      "Major" = "#ffb4ab",      # Error color from our dark theme
      "Moderate" = "#ffde9c",   # Dark mode warning color
      "Minor" = "#97f5c4",      # Dark mode success color
      "Unknown" = "#8b9198"     # Dark mode neutral color
    )
    
    plot_ly(labels = names(severity_counts), 
            values = severity_counts,
            type = 'pie',
            marker = list(colors = colors[names(severity_counts)]),
            textinfo = 'label+percent') %>%
      layout(
        title = list(
          text = "Distribution of Interaction Severity",
          font = list(color = "#e2e2e6")
        ),
        paper_bgcolor = "#202224",
        plot_bgcolor = "#202224",
        font = list(color = "#e2e2e6"),
        showlegend = TRUE,
        legend = list(bgcolor = "#202224", font = list(color = "#e2e2e6"))
      )
  })
  
  # Top drugs bar chart
  output$top_drugs_bar <- renderPlotly({
    drug_counts <- c(table(drug_data$Drug_A), table(drug_data$Drug_B))
    top_drugs <- sort(drug_counts, decreasing = TRUE)[1:10]
    
    plot_ly(x = names(top_drugs),
            y = top_drugs,
            type = "bar",
            marker = list(color = "#90ccff")) %>%  # Primary color from our dark theme
      layout(
        title = list(
          text = "Most Common Drugs in Interactions",
          font = list(color = "#e2e2e6")
        ),
        paper_bgcolor = "#202224",
        plot_bgcolor = "#202224",
        font = list(color = "#e2e2e6"),
        xaxis = list(
          title = "Drug Name",
          tickfont = list(color = "#e2e2e6"),
          gridcolor = "#41474d",
          zerolinecolor = "#41474d"
        ),
        yaxis = list(
          title = "Number of Interactions",
          tickfont = list(color = "#e2e2e6"),
          gridcolor = "#41474d",
          zerolinecolor = "#41474d"
        )
      )
  })
  
  # React to the check button
  interaction_result <- eventReactive(input$check, {
    result <- drug_data %>%
      filter(
        (Drug_A == input$drug1 & Drug_B == input$drug2) |
          (Drug_A == input$drug2 & Drug_B == input$drug1)
      )
    
    if(nrow(result) == 0) {
      return(list(
        found = FALSE,
        text = "No known interactions found in database.",
        data = NULL
      ))
    } else {
      return(list(
        found = TRUE,
        data = result
      ))
    }
  })
  
  # Display interaction result
  output$interaction_result <- renderUI({
    format_interaction_result(interaction_result())
  })
  
  # Display detailed interaction table
  output$interaction_table <- renderDT({
    req(interaction_result()$found)
    datatable(interaction_result()$data,
              options = list(
                dom = 't',
                initComplete = JS("
                  function(settings, json) {
                    $(this.api().table().container()).addClass('material-card');
                  }")
              ),
              rownames = FALSE) %>%
      formatStyle('Level',
                  backgroundColor = styleEqual(
                    c("Major", "Moderate", "Minor", "Unknown"),
                    c("#93000a", "#4d3800", "#063", "#3b3b3f")
                  ),
                  color = styleEqual(
                    c("Major", "Moderate", "Minor", "Unknown"),
                    c("#ffdad6", "#ffde9c", "#97f5c4", "#e2e2e6")
                  ))
  })
  
  # Display related interactions
  output$all_interactions <- renderDT({
    # Get interactions involving drugs selected by user if any are selected
    related_interactions <- drug_data %>%
      filter(
        Drug_A %in% c(input$drug1, input$drug2) |
          Drug_B %in% c(input$drug1, input$drug2)
      ) %>%
      # If no drugs selected, show all interactions
      {if(nrow(.) == 0) drug_data else .} %>%
      # Take most relevant interactions (those with higher severity first)
      arrange(factor(Level, levels = c("Major", "Moderate", "Minor", "Unknown"))) %>%
      head(10)
    
    datatable(related_interactions,
              options = list(
                pageLength = 10,
                scrollY = "400px",
                scrollCollapse = TRUE,
                dom = 'frtip',
                initComplete = JS("
                  function(settings, json) {
                    $(this.api().table().container()).addClass('material-card');
                  }")
              ),
              caption = "Top Related Interactions",
              rownames = FALSE) %>%
      formatStyle('Level',
                  backgroundColor = styleEqual(
                    c("Major", "Moderate", "Minor", "Unknown"),
                    c("#93000a", "#4d3800", "#063", "#3b3b3f")
                  ),
                  color = styleEqual(
                    c("Major", "Moderate", "Minor", "Unknown"),
                    c("#ffdad6", "#ffde9c", "#97f5c4", "#e2e2e6")
                  ))
  })
}