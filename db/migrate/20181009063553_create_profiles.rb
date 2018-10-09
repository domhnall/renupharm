class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.belongs_to :user, foreign_key: true
      t.string :first_name
      t.string :surname
      t.string :telephone
      t.string :role
      t.timestamps
    end
  end
end
