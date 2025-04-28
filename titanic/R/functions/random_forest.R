train_random_forest <- function(titanic_train) {
  p <- ncol(titanic_train) - 1
  search_grid <- expand.grid(
    mtry = seq(floor(sqrt(p)), p / 2, length.out = 8),
    splitrule = c("gini", "extratrees"),
    min.node.size = c(1, 3, 5, 7, 10)
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
    method = "ranger",
    metric = "ROC",
    tuneGrid = search_grid,
    trControl = cv_control,
    importance = "impurity",
    num.trees = 1000,
    max.depth = 8,
    sample.fraction = 0.632,
    replace = FALSE
  )
  return(best_model)
}
