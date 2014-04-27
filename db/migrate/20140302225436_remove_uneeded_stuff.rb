class RemoveUneededStuff < ActiveRecord::Migration
  def change
    drop_table :memes
    drop_table :feedback
  end
end
