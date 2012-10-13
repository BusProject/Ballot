class AddVotesToChoices < ActiveRecord::Migration
  def change
    add_column :choices, :votes, :integer, :default => 1
  end
end
