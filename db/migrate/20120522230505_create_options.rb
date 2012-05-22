class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.references :choice
      t.integer :position
      t.string :photo
      t.text :blurb
      t.string :name

      t.timestamps
    end
    add_index :options, :choice_id
    add_index :options, :name
  end
end
