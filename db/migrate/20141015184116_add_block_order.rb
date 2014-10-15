class AddBlockOrder < ActiveRecord::Migration
  def change
    add_column :blocks, :block_order, :integer, :default => 0, :null => false
  end
end
