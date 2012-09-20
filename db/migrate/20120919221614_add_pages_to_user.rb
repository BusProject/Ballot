class AddPagesToUser < ActiveRecord::Migration
  def change
    add_column :users, :pages, :text
  end
end
