find_optimal_weights <- function(train_data) {
  # Create empty dataframes for out-of-fold predictions
  train_data <- train_data |> select(-NameLetter)
  no_of_folds <- 5
  proportion <- 0.7
  no_of_samples <- round(nrow(train_data) * proportion)
  train_folds <- replicate(no_of_folds, sample(1:nrow(train_data), size = no_of_samples, replace = FALSE), simplify = FALSE)
  oof_rf <- replicate(no_of_folds, c())
  oof_gbm <- replicate(no_of_folds, c())
  oof_glmnet <- replicate(no_of_folds, c())
  real_responses <- replicate(no_of_folds, c())
  
  # Generate out-of-fold predictions
  for(i in seq_along(train_folds)) {
    print(paste(i, "out of", no_of_folds, "training runs", sep = " "))
    # Split data
    fold_idx <- train_folds[[i]]
    train_fold <- train_data[-fold_idx, ]
    valid_fold <- train_data[fold_idx, ]
    
    # Train models
    # 
    rf_fold <- train_random_forest(train_fold)
    gbm_fold <- train_gradient_boosting(train_fold)
    glmnet_fold <- train_glm(train_fold)
    
    # Store predictions
    real_responses[[i]] <- as.numeric(train_data[fold_idx,]$Survived) -1
    oof_rf[[i]] <- predict(rf_fold, newdata = valid_fold, type = "prob")$DidSurvive
    oof_gbm[[i]] <- predict(gbm_fold, data = valid_fold, type = "prob")$DidSurvive
    oof_glmnet[[i]]<- predict(glmnet_fold, data = valid_fold, type = "prob")$DidSurvive
  }
  real_responses_vec <- unlist(real_responses)
  oof_rf_vec <- unlist(oof_rf)
  oof_gbm_vec<- unlist(oof_gbm)
  oof_glmnet_vec <- unlist(oof_glmnet)

  
  # Prepare data for weight optimization
  target <- as.numeric(train_data$Survived) - 1
  
  # Create weight grid
  weights_grid <- expand.grid(
    w_rf = seq(0.15, 0.7, by = 0.05),
    w_gbm = seq(0.15, 0.7, by = 0.05)
  ) |> filter(w_rf + w_gbm <= 1.0)
  weights_grid$w_glmnet <- 1 - (weights_grid$w_rf + weights_grid$w_gbm)
  
  # Find best weights
  best_accuracy <- 0
  best_weights <- c(0.33, 0.33, 0.34)
  
  for(i in 1:nrow(weights_grid)) {
    w <- as.numeric(weights_grid[i, ])
    ensemble_preds <- w[1] * oof_rf_vec + w[2] * oof_gbm_vec + w[3] * oof_glmnet_vec
    ensemble_binary <- ifelse(ensemble_preds >= 0.5, 1, 0)
    accuracy <- mean(ensemble_binary == real_responses_vec)
    
    if(accuracy > best_accuracy) {
      best_accuracy <- accuracy
      best_weights <- w
    }
  }
  
  cat("Best weights: RF =", best_weights[1], "GBM =", best_weights[2], 
      "GLMNet =", best_weights[3], "with accuracy =", best_accuracy, "\n")
  
  return(best_weights)
}
