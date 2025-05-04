require Explorer.DataFrame, as: DF

defmodule Files.ReadData do
  def titanic_train() do
    DF.from_csv(Application.fetch_env!(:titanic_elixir, :train_file_location))
  end

  def titanic_test() do
    DF.from_csv(Application.fetch_env!(:titanic_elixir, :test_file_location))
  end
end
