class CreateElectionballots < ActiveRecord::Migration
  def change
    create_table :electionballots do |t|
      t.references :electionday
      t.string :name
      t.text :notes
      t.boolean :open, :default => true
      
      t.timestamps
    end
  end
end
