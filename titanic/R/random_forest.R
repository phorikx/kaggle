library(randomForest)
library(ggplot2)
library(ranger)
library(caret)
library(dplyr)
library(tibble)
library(readr)
library(mice)
library(purrr)

# Basis voorbereidingen treffen - wat betreft het laden van paden, etc.
basis_map <- "/home/paul/projects/kaggle/titanic"
data_map <- file.path(basis_map, "data")
output_map <- file.path(basis_map, "output")
functie_map <- file.path(basis_map, "R", "functions")
list.files(path = functie_map, pattern = "\\.[Rr]$", full.names = TRUE) |> walk(source)

titanic_train_file <- read_csv(file.path(data_map, "train.csv")) 
titanic_test_file <- read_csv(file.path(data_map, "test.csv"))

trim_data <- function(data, is_train = TRUE) {
  features <- c("Pclass", "Sex", "AgeBin", "FareBin",
   "Title", "FamilySize", "IsAlone", "FareBin", "Deck", "Embarked", "LogFare")
  features <- if (is_train) {
    c("Survived",features)
    } else {
      features
    }

  data |> select(features)
}

# Data aanpassen aan 
titanic_train <- modify_titanic(titanic_train_file) |> 
  trim_data()
titanic_test <- modify_titanic(titanic_test_file, is_train = FALSE) |> trim_data(is_train = FALSE)

summary_function <- function(data, lev = NULL, model = NULL) {
  c(twoClassSummary(data, lev, model),
  Accuracy = sum(data$pred == data$obs) / length(data$obs))
}

tune_model <- function(data, search, summary_function = twoClassSummary) {
  cv_control <- trainControl(
    method = "cv",
    number = 10,
    verboseIter = FALSE,
    classProbs = TRUE,
    summaryFunction = summary_function,
    savePredictions = "final",
    returnResamp = "all"
  )

  train(Survived ~ . + Sex:Pclass + AgeBin:Pclass + FamilySize:Sex , 
    data = data,
    method = "ranger",
    metric = "ROC",
    tuneGrid = search,
    trControl = cv_control,
    importance = "impurity", 
    num.trees = 1000,
    max.depth = 10,
    sample.fraction = 0.8)

}

# Evaluate several different hyperparameters
p <- ncol(titanic_train) - 1
search_grid <- expand.grid(
  mtry = 1:4,
  splitrule = c("gini", "extratrees"),
  min.node.size = 1:5
)
tuned <- tune_model(titanic_train, search = search_grid, summary_function = summary_function)
best_model <- tuned$finalModel
titanic_test$Survived <- factor(NA, levels = levels(titanic_train$Survived))
prediction_best <- predict(tuned, newdata = titanic_test)
prediction_best

# Beste model zoals eerder gemaakt wegschrijven
output <- tibble(PassengerId = titanic_test_file$PassengerId, Survived = as.integer(prediction_best) - 1)
head(output)

write.csv(output, file.path(output_map, "submission_random_forest.csv"), row.names = FALSE, quote = FALSE)

# Custom model proberen
gen_model <- function(data_train) {
  cv_control <- trainControl(
    method = "cv",
    number = 5,
    verboseIter = FALSE,
    classProbs = TRUE,
    summaryFunction = summary_function
  )
  train(Survived ~ ., 
    data = data_train,
    method = "ranger",
    metric = "ROC",
    max_depth = 5,
    trControl = cv_control,
    ntree = 500,
    mtry = 2,
    min.node.size = 1,
    splitrule = "gini",
    importance = "impurity")
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


model <- gen_model(titanic_train)
var_importance <- varImp(model, scale = TRUE)
print(var_importance)

prediction <- pred(model, titanic_test)
prediction_best <- pred(best_model, titanic_test)

# Zelf gemaakte model wegschrijven
output <- tibble(PassengerId = titanic_test_file$PassengerId, Survived = as.integer(prediction) - 1)
head(output)

write.csv(output, file.path(output_map, "submission_random_forest.csv"), row.names = FALSE, quote = FALSE)

