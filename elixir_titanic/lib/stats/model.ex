require Explorer.DataFrame, as: DF

defmodule Stats.Model do
  def train_model(data) do
    %{model: :a}
  end

  def make_predictions(model, data) do
    DF.new(a: "cat")
  end
end
