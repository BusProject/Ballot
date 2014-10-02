class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.references :guide
      t.references :option
      t.references :user_option
      t.string :title
      t.text :content

      t.timestamps
    end
    add_index :blocks, :guide_id
    add_index :blocks, :option_id
    add_index :blocks, :user_option_id
  end
end
