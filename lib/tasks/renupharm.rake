require "#{Rails.root}/spec/support/factories"

namespace :renupharm do
  desc "Set up dev database"
  task setup_dev: [:environment, "db:drop", "db:create", "db:migrate", "db:seed"] do
    include Factories::Base
    include Factories::Marketplace

    # Create users
    daniel = create_daniel
    johnny = create_johnny

    # Create pharmacies
    larussos = create_larussos.tap do |pharmacy|
      pharmacy.agents.create(user: daniel)
    end

    lawrences = create_lawrences.tap do |pharmacy|
      pharmacy.agents.create(user: johnny)
    end
  end
end
