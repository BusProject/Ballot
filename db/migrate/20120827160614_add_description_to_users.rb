class AddDescriptionToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :base_address
    add_column :users, :description, :text
    add_column :users, :fb_friends, :text
    add_column :users, :alerts, :text
  end
end
