class AddImageAndNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :image, :string
    add_column :users, :name, :string
    add_column :users, :location, :string
    add_column :users, :url, :string
  end
end
