class CreateFeedback < ActiveRecord::Migration
  def change
    create_table :feedback do |t|
      t.references :user
      t.references :option
      t.boolean :support, :default => false
      t.boolean :approved, :default => true
      t.text :comment

      t.timestamps
    end
    add_index :feedback, :option_id
    add_index :feedback, :user_id

  end
end
