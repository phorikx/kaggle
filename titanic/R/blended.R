prediction_reg_reg_prob
predictions_random_forest_prob

predictions_blended = 0.6 * prediction_random_forest_prob$DidSurvive + 0.4 * prediction_reg_reg_prob
output <- tibble(PassengerId = titanic_test$PassengerId, Survived = predictions_blended |> round()) |> 
  mutate(Survived = round(Survived))
head(output)

write.csv(output, file.path(output_map, "submission_regularized_regression.csv"), row.names = FALSE, quote = FALSE)
