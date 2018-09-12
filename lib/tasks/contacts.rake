require 'csv'

namespace :renupharm do
  desc "Exporting contacts for upload to SendGrid contact list"
  task export_sales_pharmacies_for_sendgrid: [:environment] do
    CSV.open("#{Rails.root}/sendgrid_contacts.csv", "wb") do |csv|
      csv << ["first_name", "last_name", "email", "sales_pharmacy_id"]
      Sales::Pharmacy.where.not(email: nil).each do |pharmacy|
        csv << [pharmacy.name, pharmacy.address_3, pharmacy.email, pharmacy.id]
      end
     end
  end
end
