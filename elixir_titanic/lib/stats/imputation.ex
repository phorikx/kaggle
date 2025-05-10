require Explorer.DataFrame, as: DF

defmodule Stats.Imputation do
  def impute(data) do
    data
    |> DF.mutate(
      embarked: if(is_nil(embarked), do: "S", else: embarked),
      fare: if(is_nil(fare), do: Explorer.Series.mean(fare), else: fare),
      sibsp: if(is_nil(sibsp), do: 0, else: sibsp),
      parch: if(is_nil(parch), do: 0, else: parch),
      age: if(is_nil(age), do: Explorer.Series.mean(age), else: age)
    )
  end
end
