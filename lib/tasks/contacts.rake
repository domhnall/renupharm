require 'csv'

namespace :renupharm do
  desc "Exporting contacts for upload to SendGrid contact list"
  task export_contacts_for_sendgrid: [:environment] do
    CSV.open("#{Rails.root}/sendgrid_contacts.csv", "wb") do |csv|
      csv << ["first_name", "last_name", "email"]
      Sales::Pharmacy.where.not(email: nil).each do |pharmacy|
        csv << [pharmacy.name, pharmacy.address_3, pharmacy.email]
      end
     end
  end
end
