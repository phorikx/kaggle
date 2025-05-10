summary_function <- function(data, lev = NULL, model = NULL) {
  c(twoClassSummary(data, lev, model),
  Accuracy = sum(data$pred == data$obs) / length(data$obs))
}

cv_control <- trainControl(
  method = "cv",
  number = 10,
  verboseIter = FALSE,
  classProbs = TRUE,
  summaryFunction = summary_function,
  savePredictions = "final",
  returnResamp = "all"
)
