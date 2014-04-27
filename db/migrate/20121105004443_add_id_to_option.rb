class AddIdToOption < ActiveRecord::Migration
  def change
    add_column :options, :vip_id, :string
  end
end
