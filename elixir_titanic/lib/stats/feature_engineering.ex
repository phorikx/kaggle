require Explorer.DataFrame, as: DF

defmodule Stats.FeatureEngineering do
  def update_data(data) do
    updated_data = update_dataframe(data)

    values = DF.select(data, "Survived") |> Nx.concatenate()

    {:ok, updated_data, values}
  end

  def update_dataframe(data) do
    DF.rename_with(data, &String.downcase/1)
    |> Stats.Imputation.impute()
    |> DF.mutate(
      sex: cast(sex, :category),
      embarked: cast(embarked, :category)
    )
    |> DF.select(["embarked", "sex", "sibsp", "parch", "pclass", "fare"])
    |> Nx.stack(axis: 1)
  end
end
