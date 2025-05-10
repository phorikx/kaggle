train_gradient_boosting <- function(titanic_train) {
  search_grid <- expand.grid(
    n.trees = c(500, 1000, 1500, 2000),
    interaction.depth = c(2, 3, 4),
    shrinkage = c(0.01, 0.005, 0.001),
    n.minobsinnode = c(10, 15, 20)
  )

  best_model <- train(
    Survived ~
      . +
        Sex:Pclass +
        AgeBin:Pclass +
        FamilySize:Sex +
        Sex:FarePerPerson +
        AgeBin:Sex,
    data = titanic_train,
    method = "gbm",
    metric = "ROC",
    tuneGrid = search_grid,
    trControl = cv_control,
    verbose = FALSE
  )
  return(best_model)
}
