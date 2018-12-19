class AddAcceptedTermsAtToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :accepted_terms_at, :datetime
  end
end
