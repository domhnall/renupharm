class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.belongs_to :profile, foreign_key: true
      t.string :type
      t.string :title
      t.string :message
      t.json :options
      t.boolean :delivered, default: false
      t.json :gateway_response
    end
  end
end
