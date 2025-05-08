import Config
config :nx, :default_backend, EXLA.Backend
config :nx, :default_defn_options, compiler: EXLA, client: :host

config :titanic_elixir, :train_file_location, "./fixtures/titanic_train.csv"
config :titanic_elixir, :test_file_location, "./fixtures/titanic_test.csv"
config :titanic_elixir, :output_file_location, "./output/titanic_submission.csv"
