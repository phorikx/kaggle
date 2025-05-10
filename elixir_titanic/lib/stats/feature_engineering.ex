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
      embarked: if(is_nil(embarked), do: "Southampton", else: embarked),
      pclass: cast(pclass, :string),
      title: Explorer.Series.re_replace(name, ~S/(.*, )|(\..*)/, ""),
      family_size: 1 + sibsp + parch,
      mother: sex == "Female" and parch > 0,
      cabin: if(is_nil(cabin), do: "U", else: cabin)
    )
    |> DF.mutate(
      title: if(title == "Mlle" or title == "Ms", do: "Miss", else: title),
      is_alone: family_size == 1,
      embarked: cast(embarked, :category),
      log_fare: if(fare == 0, do: 0, else: Explorer.Series.log(fare)),
      has_parent: parch > 0 and age < 20,
      has_sibling: sibsp > 0,
      large_family: family_size >= 4,
      small_family: 2 <= family_size and 3 >= family_size,
      fare_per_person: fare / family_size,
      young_miss: title == "Miss" and age < 18,
      deck: Explorer.Series.substring(cabin, 0, 1)
    )
    |> DF.mutate(
      title: if(title == "Mme", do: "Mrs", else: title),
      deck: cast(deck, :category)
    )
    |> DF.mutate(title: if(Enum.member?(rare_titles(), title), do: "Rare", else: title))
    |> DF.select([
      "embarked",
      "sex",
      "sibsp",
      "parch",
      "pclass",
      "fare",
      "title",
      "is_alone",
      "log_fare",
      "has_parent",
      "has_sibling",
      "large_family",
      "small_family",
      "fare_per_person",
      "young_miss",
      "deck",
      "mother",
      "family_size"
    ])
    |> Nx.stack(axis: 1)
  end

  def rare_titles() do
    [
      "Dona",
      "Lady",
      "the Countess",
      "Capt",
      "Col",
      "Don",
      "Dr",
      "Major",
      "Rev",
      "Sir",
      "Jonkheer"
    ]
  end
end
