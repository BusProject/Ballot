class AddFullSizeToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :full_size, :boolean
  end
end
