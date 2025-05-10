evaluate_model <- function(data, generate_model, pred, eval){
  1:10 |> sapply(function(x) {
    test_part <- sample(x = 1:nrow(data), size = floor(0.25*nrow(data)), replace = FALSE)
    data_test <- data |> slice(test_part)
    data_train <- data |> slice(-test_part)

    model <- generate_model(data_train)

    predicted <- pred(model, data_test)

    score <- eval(predicted, data_test)
  }) |> mean()
}
