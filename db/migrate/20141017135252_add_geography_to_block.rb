class AddGeographyToBlock < ActiveRecord::Migration
  def change
        add_column :blocks, :geography, :string
  end
end
