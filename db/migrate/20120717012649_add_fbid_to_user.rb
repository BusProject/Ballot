class AddFbidToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb, :string
    
  end
end
