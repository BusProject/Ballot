class CreateUserOption < ActiveRecord::Migration
  def change
    create_table :user_options do |t|
      t.references :choice
      t.references :user
      t.integer :position
      t.string :photo
      t.text :blurb
      t.string :name

      t.timestamps
    end
    add_index :user_options, :choice_id
    add_index :user_options, :user_id
    add_index :user_options, :name
  end
end
