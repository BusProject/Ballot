class ChangeBlockOrderToNutNull < ActiveRecord::Migration
  def change
    change_column :blocks, :order, :integer, :default => 0, :null => false
  end
end
