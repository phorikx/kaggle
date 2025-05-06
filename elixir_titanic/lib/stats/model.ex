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
      num_boost_rounds: 100,
      evals: [{data, values, "training"}],
      verbose_eval: true
    )
  end

  def make_predictions(model, data) do
    {:ok, data_format, _} = Stats.FeatureEngineering.update_data(data)
    {:ok,
      EXGBoost.predict(model, data_format)
    }
  end
end
