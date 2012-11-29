class RemoveIndexFromChoices < ActiveRecord::Migration
  def up
    remove_index :choices, [ :geography, :contest]
    add_index :choices, [ :geography, :contest, :electionballot_id ], :unique => true
  end

  def down
    remove_index :choices, [ :geography, :contest, :electionballot_id ]
    
  end
end
