class AddMatchBack < ActiveRecord::Migration

  def up
  	drop_table :matches
    create_table :matches do |t|
      t.string :query
      t.string :state
      t.string :match_type

      t.timestamps
    end
  end
  def down
  	drop_table :matches
  end
end
