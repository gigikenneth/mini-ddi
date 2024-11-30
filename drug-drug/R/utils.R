create_severity_chip <- function(severity) {
  sprintf('<span class="severity-chip severity-%s">%s</span>',
          tolower(severity),
          severity)
}

format_interaction_result <- function(result) {
  if (result$found) {
    HTML(sprintf(
      "<div class='interaction-result'>
        <div>Severity: %s</div>
        <div>Interaction IDs: %s - %s</div>
       </div>",
      create_severity_chip(result$data$Level),
      result$data$DDInterID_A,
      result$data$DDInterID_B
    ))
  } else {
    HTML("<div class='no-interaction'>No known interactions found in database.</div>")
  }
}