require Explorer.DataFrame, as: DF
require Explorer.Series

defmodule Stats.Model do
  def train_model(data, values) do
    EXGBoost.train(
      data,
      values,
      booster: :gbtree,
      tree_method: :auto,
      objective: :reg_squarederror,
      num_boost_rounds: 1000,
      subsample: 0.8,
      grow_policy: :lossguide,
      max_depth: 5,
      evals: [{data, values, "training"}],
      verbose_eval: true
    )
  end

  def make_predictions(model, data, passenger_ids) do
    data_format = Stats.FeatureEngineering.update_dataframe(data)
    predictions = EXGBoost.predict(model, data_format)

    predictions_nice =
      predictions
      |> Nx.round()
      |> Nx.as_type(:s64)
      |> Nx.max(Nx.tensor(List.duplicate(0, Nx.size(predictions))))

    predict_df =
      DF.new(PassengerId: passenger_ids, Survived: Explorer.Series.from_tensor(predictions_nice))

    {:ok, predict_df}
  end
end
