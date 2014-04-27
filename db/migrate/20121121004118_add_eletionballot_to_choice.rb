class AddEletionballotToChoice < ActiveRecord::Migration
  def change
    add_column :choices, :electionballot_id, :integer
  end

end
