class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.string :contest
      t.integer :order
      t.boolean :commentable, :default => false
      t.string :geography
      t.text :description
      t.string :contest_type
      
      t.timestamps
    end

    add_index :choices, [ :geography, :contest], :unique => true
  end
end
