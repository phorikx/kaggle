require Explorer.DataFrame, as: DF
require Explorer.Series

defmodule Stats.Model do
  def train_model(data) do
    %{model: :a}
  end

  def make_predictions(model, data) do
    {:ok, DF.new(animal: Explorer.Series.from_list(["cat", "dog"]), weight: Explorer.Series.from_list([8, 25]))}
  end
end
