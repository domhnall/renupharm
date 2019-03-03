class CreateWebPushSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :web_push_subscriptions do |t|
      t.belongs_to :profile, foreign_key: true
      t.json :subscription
      t.timestamps
    end
  end
end
