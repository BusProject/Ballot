class CreateElectiondays < ActiveRecord::Migration
  def change
    create_table :electiondays do |t|
      t.date :date
      t.string :election_type
      t.string :name
      
      t.timestamps
    end
  end
end
