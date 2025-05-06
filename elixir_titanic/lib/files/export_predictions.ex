require Explorer.DataFrame, as: DF

defmodule Files.ExportPredictions do
  def write_predictions(predictions) do
    DF.to_csv(predictions, Application.fetch_env!(:titanic_elixir, :test_file_location),
      header: true
    )
  end
end
