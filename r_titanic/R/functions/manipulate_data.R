modify_titanic <- function(data, is_train = TRUE) {
  rare_titles <- c('Dona', 'Lady', 'the Countess','Capt', 'Col', 'Don', 
                  'Dr', 'Major', 'Rev', 'Sir', 'Jonkheer')

  data_survived <- if (is_train) {
      data |> mutate(
        Survived = factor(Survived, levels = c(0, 1), labels = c("DidNotSurvive", "DidSurvive")),
      )
    } else {
      data
    }

  data_tbi <- data_survived |>
    mutate(Sex = factor(Sex, levels = c("male", "female")),
      Title = gsub("(.*, )|(\\..*)", "", Name),
      Title = case_when(Title == "Mlle" ~ "Miss",
      Title == "Ms" ~ "Miss",
      Title == "Mme" ~ "Mrs",
      Title %in% rare_titles ~ "Rare",
      TRUE ~ Title) |> as.factor(),
      Embarked = factor(Embarked, levels = c("C", "Q","S"), labels = c("Cherbourg", "Queenstown", "Southampton")),
      Pclass = factor(Pclass, levels = c(1, 2, 3), labels = c("Upper", "Middle", "Lower")),
      FamilySize = 1 + SibSp + Parch,
      Mother = (Sex == "female" & Parch > 0) |> as.factor(),
      NameLetter = substring(Name, 1, 1),
      IsAlone = ifelse(FamilySize == 1, "Alone", "NotAlone") |> as.factor(),
      LogFare = ifelse(is.na(Fare) | Fare == 0, 0, log(Fare)),
      HasParent = (Parch > 0) |> as.factor(),
      HasSibling = (SibSp > 0) |> as.factor(),
      LargeFamily = (FamilySize >= 4) |> as.factor(),
      SmallFamily = (FamilySize >= 2 & FamilySize <= 3) |> as.factor()
    )

  imp <- mice(data_tbi, method = "norm")

  data_imputed <- data_tbi |> mutate(
    Age = complete(imp)$Age |> round(),
    Fare = complete(imp)$Fare |> round(),
    YoungMiss = (Title == "Miss" & Age < 18) |> as.factor(),
    FarePerPerson = Fare / (FamilySize),
    Cabin = ifelse(is.na(Cabin), "U", Cabin),
    Embarked = if_else(is.na(Embarked), "Southampton", Embarked),
    Deck = substring(Cabin, 1, 1) |> factor(levels = c("A", "B", "C", "D", "E", "F", "G", "T", "U")),
    AgeBin = cut(Age, breaks = c(-100,12, 18, 30, 50, 65, 1111), labels = c("Child", "Teen", "YoungAdult", "MiddleAged", "Senior", "Elderly")),
    FareBin = cut(Fare, breaks = c(-1000, 8, 15, 31, 10000), labels = c("Low", "MedLow", "MedHigh","High"))
  ) 

  return(data_imputed)
}
