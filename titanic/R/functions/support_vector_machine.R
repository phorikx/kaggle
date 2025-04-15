train_svm <- function(train_data, select_cols) {
  train_data <- train_data |> select(select_cols) %>%
    model.matrix(~ . - 1, data = .) %>%
    as.data.frame()

  svm_grid <- expand.grid(
    sigma = c(0.01, 0.02, 0.0, 0.1),
    C = c(0.5, 1, 2, 5, 10)
  )

  svm_model <- train(
    SurvivedDidSurvive ~ .,
    data = train_data,
    method = "svmRadial",
    preProcess = c("center", "scale"),
    metric = "ROC",
    tuneGrid = svm_grid,
    trControl = cv_control
  )
  colnames(train_data) <- g
}
