# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

Dir.glob(Rails.root.join("db/pharmacy_contact_lists/*.csv")).each do |filename|
  CSV.foreach(filename) do |row|
    row       = row.map{ |field| field && field.strip }
    name      = row[2].split(",")[0].strip
    address_1 = row[2].split(",")[1].strip
    Sales::Pharmacy.where(name: name, address_1: address_1, address_3: row[0]).first_or_create do |pharmacy|
      pharmacy.proprietor  = row[1]
      pharmacy.name        = name
      pharmacy.address_1   = address_1
      pharmacy.address_2   = row[2].split(",").drop(2).join(",").strip
      pharmacy.address_3   = row[0]
      pharmacy.telephone_1 = row[3]
      pharmacy.telephone_2 = row[4]
      pharmacy.email       = row[5]
    end
  end
end

# Create users

User.where(email: "dev@renupharm.ie").first_or_create do |user|
  user.email = "dev@renupharm.ie"
  user.password = "handbag"
  user.password_confirmation = "handbag"
  user.skip_confirmation!
  user.confirm
end.save!
