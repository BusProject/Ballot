class RemoveOrderAddExternalKey < ActiveRecord::Migration
  def change

    add_column :choices, :external_id, :integer
    add_column :choices, :fiscal_impact, :text
    add_column :choices, :description_source, :text

    add_column :options, :external_id, :integer
    add_column :options, :incumbent, :boolean, :default => false

    remove_column :choices, :order
    remove_column :choices, :electionballot_id
    remove_column :options, :vip_id
    remove_column :options, :position
    remove_column :options, :incumbant
    remove_column :options, :blurb_source

    add_index :choices, :external_id
    add_index :options, :external_id

  end
end
