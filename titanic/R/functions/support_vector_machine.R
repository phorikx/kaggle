train_svm <- function(train_data, select_cols) {
  data_transformer <- function(new_data) {
    new_data_svm <- new_data %>%
      select(all_of(select_cols)) %>%
      model.matrix(~ . - 1, data = .) %>%
      as.data.frame()

    colnames(new_data_svm) <- gsub("[^[:alnum:]]", "", colnames(new_data_svm))

    return(new_data_svm)
  }

  train_data_svm <- data_transformer(train_data) |>
    select(-c(1, 2))

  train_data_svm$Survived <- factor(
    train_data$Survived,
    levels = c("DidNotSurvive", "DidSurvive")
  )

  svm_grid <- expand.grid(
    sigma = c(0.01, 0.02, 0.0, 0.1),
    C = c(0.5, 1, 2, 5, 10)
  )

  svm_model <- train(
    Survived ~ .,
    data = train_data_svm,
    method = "svmRadial",
    preProcess = c("center", "scale"),
    metric = "ROC",
    tuneGrid = svm_grid,
    trControl = cv_control
  )

  return(list(
    model = svm_model,
    data_mut = data_transformer
  ))
}

predict_svm <- function(svm_result, new_data) {
  new_data_transformed <- svm_result$data_mut(new_data)

  predictions <- predict(
    svm_result$model,
    newdata = new_data_transformed,
    type = "prob"
  )

  return(predictions$DidSurvive)
}
