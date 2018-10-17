require "#{Rails.root}/spec/support/factories"

namespace :renupharm do
  desc "Set up dev database"
  #def create_user(attrs = {})
  #  User.new.tap do |user|
  #    user.email = attrs.fetch(:email, 'daffy@duck.com')
  #    user.password = 'foobar'
  #    user.password_confirmation = 'foobar'
  #    user.build_profile(attrs.fetch(:profile_attributes, {
  #      first_name: "Daffy",
  #      surname: "Duck",
  #      role: Profile::Roles::PHARMACY
  #    }))
  #    user.skip_confirmation!
  #    user.save!
  #    user.confirm
  #  end
  #end

  task setup_dev: [:environment, "db:drop", "db:create", "db:migrate", "db:seed"] do
    include Factories

    # Create users
    daniel = Factories.create_user({
      email: "daniel@renupharm.ie",
      profile_attributes: {
        first_name: "Daniel",
        surname: "Larusso",
        role: Profile::Roles::PHARMACY }
    }).tap do |user|
      user.profile.avatar.attach(io: File.open("#{Rails.root}/spec/support/images/karate_kid_2.jpeg"), filename: "daniel.jpeg")
    end

    johnny = Factories.create_user({
      email: "johnny@renupharm.ie",
      profile_attributes: {
        first_name: "Johnny",
        surname: "Lawrence",
        role: Profile::Roles::PHARMACY }
    }).tap do |user|
      user.profile.avatar.attach(io: File.open("#{Rails.root}/spec/support/images/karate_kid_johnny.jpeg"), filename: "johnny.jpeg")
    end

    # Create pharmacies
    Marketplace::Pharmacy.create({
      name: "Larusso's Pharmacy",
      address_1: "99 Bun Road",
      address_2: "Caketown",
      address_3: "Dundalk",
      email: "damo@renupharm.ie",
      telephone: "01234567" }).tap do |pharmacy|
      pharmacy.agents.create(user: daniel)
    end.tap do |pharmacy|
      pharmacy.image.attach(io: File.open("#{Rails.root}/spec/support/images/store_1.jpeg"), filename: "larusso.jpeg")
    end

    Marketplace::Pharmacy.create({
      name: "Lawrence's Pharmacy",
      address_1: "8 Mill St",
      address_2: "Hilltown",
      address_3: "Athlone",
      email: "conla@renupharm.ie",
      telephone: "07654321" }).tap do |pharmacy|
      pharmacy.agents.create(user: johnny)
    end.tap do |pharmacy|
      pharmacy.image.attach(io: File.open("#{Rails.root}/spec/support/images/store_2.jpeg"), filename: "lawrence.jpeg")
    end
  end
end
