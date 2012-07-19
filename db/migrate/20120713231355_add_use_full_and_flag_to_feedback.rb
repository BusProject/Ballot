class AddUseFullAndFlagToFeedback < ActiveRecord::Migration
  def change
    add_column :feedback, :useful, :text, :default => ''
    add_column :feedback, :flag, :text, :default => ''
  end
end
