class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string :latlng
      t.text :data

      t.timestamps
    end
    add_index :matches, :latlng, :unique => true
  end
end
