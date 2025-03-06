train_gradient_boosting <- function(titanic_train) {
  search_grid <- expand.grid(
    n.trees = c(1000, 2000, 3000),
    interaction.depth = c(3, 5, 7),
    shrinkage = c(0.01, 0.005),
    n.minobsinnode = c(5, 10, 15)
  )

  best_model <- train(Survived ~ . + Sex:Pclass + AgeBin:Pclass + FamilySize:Sex + Sex:FarePerPerson + AgeBin:Sex, 
                      data = titanic_train,
                      method = "gbm",
                      metric = "ROC",
                      tuneGrid = search_grid,
                      trControl = cv_control,
                      verbose = FALSE)
  return(best_model)
}

