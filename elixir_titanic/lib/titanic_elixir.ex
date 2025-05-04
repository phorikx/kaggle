require Explorer.DataFrame, as: DF

defmodule TitanicElixir do
  use Application

  @moduledoc """
  Documentation for `TitanicElixir`.
  """

  def start(_type, _args) do
    {:ok, titanic_train} = Files.ReadData.titanic_train()
    {:ok, titanic_test} = Files.ReadData.titanic_test()

    {:ok, modified_data} = Stats.FeatureEngineering.update_data(titanic_train)

    {:ok, predictions} =
      Stats.Model.train_model(modified_data)
      |> Stats.Model.make_predictions(titanic_test)

    Files.ExportPredictions.write_predictions(predictions)

    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
