require Explorer.DataFrame, as: DF

defmodule Stats.Imputation do
  def impute(data) do
    data
    |> DF.mutate(
      embarked: if(is_nil(embarked), do: "S", else: embarked),
      fare: if(is_nil(fare), do: Explorer.Series.mean(fare), else: fare)
    )
  end
end
