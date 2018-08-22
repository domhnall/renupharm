namespace :renupharm do
  desc "Set up dev database"
  task setup_dev: [:environment, "db:drop", "db:create", "db:migrate", "db:seed"] do
    # Add dev environment setup
  end
end
