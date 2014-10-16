class RemoveOrder < ActiveRecord::Migration
  def up
  	remove_column :blocks, :order
  end

  def down
  end
end
