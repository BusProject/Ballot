class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :name
      t.text :shape
      t.string :geography
      
      t.timestamps
    end
  end
end
