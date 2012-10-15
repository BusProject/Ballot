class AddMatchAndAddressToUser < ActiveRecord::Migration
  def change
    add_column :users, :match_id, :integer
    add_column :users, :address, :string
  end
end
