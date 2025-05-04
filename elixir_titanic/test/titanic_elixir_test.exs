require Explorer.DataFrame, as: DF

defmodule TitanicElixirTest do
  use ExUnit.Case
  doctest TitanicElixir

  test "reads the titanic train file correctly" do
    titanic_train = Files.TitanicTrain.titanic_train()
    assert DF.n_rows(titanic_train) == 891
    assert DF.n_columns(titanic_train) == 12
  end
end
