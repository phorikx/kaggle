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
   "Title", "FamilySize", "IsAlone", "FareBin", "Deck", "Embarked", 
    "LogFare", "Mother", "YoungMiss", "FarePerPerson", "NameLetter",
  "HasSibling", "HasParent", "LargeFamily", "SmallFamily")
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

  train(Survived ~ . + Sex:Pclass + AgeBin:Pclass + FamilySize:Sex + Sex:FarePerPerson + AgeBin:Sex, 
    data = data,
    method = "ranger",
    metric = "ROC",
    tuneGrid = search,
    trControl = cv_control,
    importance = "impurity", 
    num.trees = 1000,
    max.depth = NULL,
    sample.fraction = 0.7)

}

# Evaluate several different hyperparameters
p <- ncol(titanic_train) - 1
search_grid <- expand.grid(
  mtry = 3:8,
  splitrule = c("gini", "extratrees"),
  min.node.size = c(1,3,5,710)
)
tuned <- tune_model(titanic_train, search = search_grid, summary_function = summary_function)
best_model <- tuned$finalModel
titanic_test$Survived <- factor(NA, levels = levels(titanic_train$Survived))
prediction_best <- predict(tuned, newdata = titanic_test)
prediction_random_forest_prob <- predict(tuned, newdata = titanic_test, type = "prob")
prediction_best

# Beste model zoals eerder gemaakt wegschrijven
output <- tibble(PassengerId = titanic_test_file$PassengerId, Survived = as.integer(prediction_best) - 1)
head(output)

write.csv(output, file.path(output_map, "submission_random_forest.csv"), row.names = FALSE, quote = FALSE)
