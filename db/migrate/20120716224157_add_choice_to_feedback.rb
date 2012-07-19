class AddChoiceToFeedback < ActiveRecord::Migration
  def change
    add_column :feedback, :choice_id, :integer
    
  end
end
