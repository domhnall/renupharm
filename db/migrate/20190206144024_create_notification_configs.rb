class CreateNotificationConfigs < ActiveRecord::Migration[5.2]
  def up
    create_table :notification_configs do |t|
      t.belongs_to :profile, foreign_key: true
      t.boolean :purchase_emails, default: true
      t.boolean :purchase_texts, default: true
      t.boolean :purchase_site_notifications, default: true
      t.boolean :sale_emails, default: true
      t.boolean :sale_texts, default: true
      t.boolean :sale_site_notifications, default: true
      t.timestamps
    end

    execute "INSERT INTO notification_configs(profile_id, created_at, updated_at) SELECT id, NOW(), NOW() FROM profiles;"
  end

  def down
    drop_table :notification_configs
  end
end
