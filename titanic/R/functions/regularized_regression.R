train_glm <- function(titanic_train) {
  x <- model.matrix(Survived ~ Pclass + Sex + FarePerPerson + Mother + LogFare + IsAlone + FamilySize + Title + AgeBin + AgeBin*Sex + Pclass * Sex - 1, data = titanic_train)
  y <- as.numeric(titanic_train$Survived) - 1

  search_grid <- expand.grid(
    alpha = c(0, 0.3, 0.5, 0.7, 1),
    lambda = 10^seq(-5, -1, length.out = 10)
  )

  model <- train(
    x = x,
    y = factor(y, levels = c(0,1), labels = c("DidNotSurvive", "DidSurvive")),
    method = "glmnet",
    metric = "ROC",
    tuneGrid = search_grid,
    trControl = cv_control
  )

  return(model)
}
