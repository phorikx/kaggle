find_optimal_weights <- function(train_data) {
  # Create empty dataframes for out-of-fold predictions
  train_folds <- createFolds(train_data$Survived, k = 5)
  oof_rf <- numeric(nrow(train_data))
  oof_gbm <- numeric(nrow(train_data))
  oof_glmnet <- numeric(nrow(train_data))
  
  # Generate out-of-fold predictions
  for(i in seq_along(train_folds)) {
    # Split data
    fold_idx <- train_folds[[i]]
    train_fold <- train_data[-fold_idx, ]
    valid_fold <- train_data[fold_idx, ]
    
    # Train models
    rf_fold <- train_random_forest(train_fold)
    gbm_fold <- train_gradient_boosting(train_fold)
    glmnet_fold <- train_glm(train_fold)
    
    # Store predictions
    oof_rf[fold_idx] <- predict(rf_fold, newdata = valid_fold, type = "prob")$DidSurvive
    oof_gbm[fold_idx] <- predict(gbm_fold, data = valid_fold, type = "prob")$DidSurvive
    oof_glmnet[fold_idx] <- predict(glmnet_fold, data = valid_fold, type = "prob")$DidSurvive
  }
  
  # Prepare data for weight optimization
  target <- as.numeric(train_data$Survived) - 1
  
  # Create weight grid
  weights_grid <- expand.grid(
    w_rf = seq(0.1, 0.8, by = 0.1),
    w_gbm = seq(0.1, 0.8, by = 0.1)
  ) |> filter(w_rf + w_gbm <= 0.9)
  weights_grid$w_glmnet <- 1 - (weights_grid$w_rf + weights_grid$w_gbm)
  
  # Find best weights
  best_accuracy <- 0
  best_weights <- c(0.33, 0.33, 0.34)
  
  for(i in 1:nrow(weights_grid)) {
    w <- as.numeric(weights_grid[i, ])
    ensemble_preds <- w[1] * oof_rf + w[2] * oof_gbm + w[3] * oof_glmnet
    ensemble_binary <- ifelse(ensemble_preds > 0.5, 1, 0)
    accuracy <- mean(ensemble_binary == target)
    
    if(accuracy > best_accuracy) {
      best_accuracy <- accuracy
      best_weights <- w
    }
  }
  
  cat("Best weights: RF =", best_weights[1], "GBM =", best_weights[2], 
      "GLMNet =", best_weights[3], "with accuracy =", best_accuracy, "\n")
  
  return(best_weights)
}
