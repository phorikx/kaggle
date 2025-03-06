library(randomForest)
library(xgboost)
library(gbm)
library(ggplot2)
library(ranger)
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

random_forest_model <- train_random_forest(titanic_train)
gradient_boosting_model <- train_gradient_boosting(titanic_train)
glm_model <- train_glm(titanic_train)

# Make predictions 
rf_preds <- predict(random_forest_model, data = titanic_test, type = "response")$DidSurvive 
gbm_preds <- predict(gradient_boosting_model, data = titanic_test, type = "prob")$DidSurvive
glm_preds <- predict(glm_model, data = titanic_test, type = "prob")$DidSurvive


optimal_weights <- find_optimal_weights()

ensemble_preds <- optimal_weights[1] * rf_preds + optimal_weights[2] * gbm_preds + optimal_weights[3]* glm_preds

# Beste model zoals eerder gemaakt wegschrijven
output <- tibble(PassengerId = titanic_test_file$PassengerId, Survived = round(ensemble_preds))
head(output)

write.csv(output, file.path(output_map, "submission_random_forest.csv"), row.names = FALSE, quote = FALSE)
