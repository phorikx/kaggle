library(dplyr)
library(tibble)
library(readr)
library(mice)
library(purrr)

data_map <- "/home/paul/projects/kaggle/titanic/data"
output_map <- "/home/paul/projects/kaggle/titanic/output"
titanic_train <- read_csv(file.path(data_map, "train.csv")) 
titanic_test <- read_csv(file.path(data_map, "test.csv"))

titanic_train <- titanic_train |>
  mutate(Sex = factor(Sex, levels = c("male", "female")),
    Survived = factor(Survived, levels = c(0, 1), labels = c("Did not survive", "Did survive")),
    Embarked = factor(Embarked, levels = c("C", "Q","S"), labels = c("Cherbourg", "Queenstown", "Southampton")),
    Pclass = factor(Pclass, levels = c(1, 2, 3), labels = c("Upper", "Middle", "Lower"))
  )
imp <- mice(titanic_train, method = "norm")
titanice_train <- complete(imp)

titanic_test <- titanic_test |>
  mutate(Sex = factor(Sex, levels = c("male", "female")),
    Embarked = factor(Embarked, levels = c("C", "Q","S"), labels = c("Cherbourg", "Queenstown", "Southampton")),
    Pclass = factor(Pclass, levels = c(1, 2, 3), labels = c("Upper", "Middle", "Lower"))
  )
imp <- mice(titanic_test, method = "norm")
titanic_test <- complete(imp)

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

gen_model <- function(data_train) {
  glm(Survived ~ Pclass + Sex + SibSp, data = data_train, family = "binomial")
}

pred <- function(model, data_test) {
  predict(model, data_test, type = "response")
}

eval <- function(predicted, data_test){
  data_test <- data_test |>
    mutate(predicted = predicted) |>
    mutate(eval = abs(as.integer(Survived) - 1 - predicted))

  mean(data_test$eval, na.rm = TRUE)
}

evaluate_model(titanic_train, gen_model, pred, eval)

output <- tibble(PassengerId = titanic_test$PassengerId, Survived = prediction) |> 
  mutate(Survived = round(Survived))
head(output)

write.csv(output, file.path(output_map, "submission.csv"), row.names = FALSE, quote = FALSE)
