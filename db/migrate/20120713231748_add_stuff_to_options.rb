class AddStuffToOptions < ActiveRecord::Migration
  def change
    add_column :options, :twitter, :string
    add_column :options, :facebook, :string
    add_column :options, :website, :string
    add_column :options, :blurb_source, :string
    add_column :options, :party, :string
    add_column :options, :incumbant, :boolean, :default => false
    
  end
end
