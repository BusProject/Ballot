class RemoveTables < ActiveRecord::Migration
  def up
  	drop_table :districts
  	drop_table :electiondays
  	drop_table :electionballots
  	drop_table :memes
  end

  def down
  end
end
