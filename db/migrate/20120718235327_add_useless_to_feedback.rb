class AddUselessToFeedback < ActiveRecord::Migration
  def change
    add_column :feedback, :useless, :text, :default => ''
    
  end
end
