require Explorer.DataFrame, as: DF

defmodule Stats.FeatureEngineering do
  def update_data(data) do
    updated_data =
      data
      |> DF.rename_with(&String.downcase/1)
      |> DF.mutate(
        sex: cast(sex, :category),
        embarked: cast(embarked, :category)
      )
      |> DF.select(["embarked", "sex", "sibsp", "parch", "pclass", "fare"])

    values = DF.select(data, "Survived") |> Nx.concatenate()

    {:ok, updated_data, values}
  end
end
