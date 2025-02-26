library(randomForest)
library(caret)
library(dplyr)
library(tibble)
library(readr)
library(mice)
library(purrr)

basis_map <- "/home/paul/projects/kaggle/titanic"
data_map <- file.path(basis_map, "data")
output_map <- file.path(basis_map, "output")
functie_map <- file.path(basis_map, "R", "functions")
list.files(path = functie_map, pattern = "\\.[Rr]$", full.names = TRUE) |> walk(source)

titanic_train_file <- read_csv(file.path(data_map, "train.csv")) 
titanic_test_file <- read_csv(file.path(data_map, "test.csv"))

trim_data <- function(data, is_train = TRUE) {
  features <- c("Pclass", "Sex", "AgeBin", "FareBin",
  "Embarked", "Title", "FamilySize", "IsAlone", "Deck")
  features <- if (is_train) {
    c("Survived",features)
    } else {
      features
    }

  data |> select(features)
}

titanic_train <- modify_titanic(titanic_train_file) |> 
  trim_data()
titanic_test <- modify_titanic(titanic_test_file, is_train = FALSE) |> trim_data(is_train = FALSE)


gen_model <- function(data_train) {
  cv_control <- trainControl(
    method = "cv",
    number = 5,
    verboseIter = FALSE,
    classProbs = TRUE,
    summaryFunction = twoClassSummary
  )
  train(Survived ~ ., 
    data = data_train,
    method = "rf",
    metric = "ROC",
    trControl = cv_control,
    ntree = 500,
    importance = TRUE)
}

pred <- function(model, data_test) {
  predict(model, data_test)
}

pred_prob <- function(model, data_test) {
  predict(model, data_test, type = "prob")
}

eval <- function(predicted, data_test){
  data_test <- data_test |>
    mutate(predicted = predicted |> as.integer()) |>
    mutate(eval = abs(as.integer(Survived) - predicted))

  mean(data_test$eval, na.rm = TRUE)
}

evaluate_model(titanic_train, gen_model, pred, eval)
evaluate_model(titanic_train, gen_model, pred_prob, eval)

model <- gen_model(titanic_train)
var_importance <- varImp(model, scale = TRUE)
print(var_importance)

prediction <- pred(model, titanic_test)

output <- tibble(PassengerId = titanic_test_file$PassengerId, Survived = as.integer(prediction) - 1)
head(output)

write.csv(output, file.path(output_map, "submission_random_forest.csv"), row.names = FALSE, quote = FALSE)
