class RemoveStufffromFeedback < ActiveRecord::Migration
  
  def up
    remove_column :feedback, :support
    remove_column :feedback, :useless
    remove_column :feedback, :useful

  end

  def down
  end
end
