class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.text :body
      t.belongs_to :user, foreign_key: true
      t.references :commentable, polymorphic: true

      t.timestamps
    end
  end
end
