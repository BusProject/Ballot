class CreateGuides < ActiveRecord::Migration
  def change
    create_table :guides do |t|
      t.references :user
      t.string :name
      t.boolean :publish

      t.timestamps
    end
    add_index :guides, :user_id
  end
end
