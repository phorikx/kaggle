library(dplyr)
library(tibble)
library(readr)
library(mice)
library(purrr)

basis_map <- "/home/paul/projects/kaggle/titanic"
data_map <- file.path(basis_map, "data")
output_map <- file.path(basis_map, "output")
functie_map <- file.path(basis_map, "R", "functies")
list.files(path = functie_map, pattern = "\\.[Rr]$", full.names = TRUE) |> walk(source)

titanic_train <- read_csv(file.path(data_map, "train.csv")) 
titanic_test <- read_csv(file.path(data_map, "test.csv"))

titanic_train <- modify_titanic(titanic_train)
titanic_test <- modify_titanic(titanic_test, is_train = FALSE )

gen_model <- function(data_train) {
  glm(Survived ~ Pclass + Sex + IsAlone + FamilySize + Title,
    data = data_train, family = "binomial")
}

pred <- function(model, data_test) {
  predict(model, data_test, type = "response")
}

eval <- function(predicted, data_test){
  data_test <- data_test |>
    mutate(predicted = predicted) |>
    mutate(eval = abs(as.integer(Survived) - 1 - round(predicted)))

  mean(data_test$eval, na.rm = TRUE)
}

evaluate_model(titanic_train, gen_model, pred, eval)

model <- gen_model(titanic_train)
prediction <- pred(model, titanic_test)

output <- tibble(PassengerId = titanic_test$PassengerId, Survived = prediction) |> 
  mutate(Survived = round(Survived))
head(output)

write.csv(output, file.path(output_map, "submission_regression.csv"), row.names = FALSE, quote = FALSE)
