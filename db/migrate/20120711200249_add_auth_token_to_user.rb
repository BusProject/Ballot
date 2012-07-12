class AddAuthTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :guide_name, :string
    add_column :users, :base_address, :string
  end
end
