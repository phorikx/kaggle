library(dplyr)
library(glmnet)
library(tibble)
library(readr)
library(mice)
library(purrr)

basis_map <- "/home/paul/projects/kaggle/titanic"
data_map <- file.path(basis_map, "data")
output_map <- file.path(basis_map, "output")
functie_map <- file.path(basis_map, "R", "functies")
list.files(path = functie_map, pattern = "\\.[Rr]$", full.names = TRUE) |> walk(source)

titanic_train_file <- read_csv(file.path(data_map, "train.csv")) 
titanic_test_file <- read_csv(file.path(data_map, "test.csv"))

titanic_train <- modify_titanic(titanic_train_file)
titanic_test <- modify_titanic(titanic_test_file, is_train = FALSE )

x <- model.matrix(Survived ~ Pclass + Sex + LogFare + IsAlone + FamilySize + Title + AgeBin + AgeBin*Sex + Pclass * Sex - 1, data = titanic_train)
y <- as.numeric(titanic_train$Survived) - 1
cv_fit <- cv.glmnet(x, y, family = "binomial", alpha = 0.5)
plot(cv_fit)
best_lambda <- cv_fit$lambda.min

x_test <- model.matrix(~ Pclass + Sex + LogFare + IsAlone + FamilySize + Title + AgeBin + AgeBin*Sex + Pclass * Sex - 1, data = titanic_train)

prediction <- predict(cv_fit, newx = x_test, s = best_lambda, type = "response")

output <- tibble(PassengerId = titanic_test$PassengerId, Survived = prediction) |> 
  mutate(Survived = round(Survived))
head(output)

write.csv(output, file.path(output_map, "submission_regularized_regression.csv"), row.names = FALSE, quote = FALSE)
