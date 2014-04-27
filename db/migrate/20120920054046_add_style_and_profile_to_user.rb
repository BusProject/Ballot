class AddStyleAndProfileToUser < ActiveRecord::Migration
  def change
    add_column :users, :profile, :string
    add_column :users, :primary, :string
    add_column :users, :secondary, :string
    add_column :users, :bg, :string
  end
end
