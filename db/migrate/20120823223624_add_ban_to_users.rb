class AddBanToUsers < ActiveRecord::Migration
  def change
      add_column :users, :banned, :boolean, :default => false
      add_column :users, :deactivated, :boolean, :default => false
  end
end
