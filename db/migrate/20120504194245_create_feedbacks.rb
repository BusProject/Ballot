class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :choice_key
      t.integer :support, :default => 0
      t.boolean :approved, :default => true
      t.text :comment
      t.references :user 

      t.timestamps
    end
    add_index :feedbacks, :choice_key
  end
end
