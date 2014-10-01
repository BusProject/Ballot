class AddDoNotEdit < ActiveRecord::Migration
  def change
  	    add_column :choices, :stop_sync, :boolean, :default => false
  	    add_column :options, :stop_sync, :boolean, :default => false
  end
end
