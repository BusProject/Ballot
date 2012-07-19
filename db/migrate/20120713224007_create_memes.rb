class CreateMemes < ActiveRecord::Migration
  def change
    create_table :memes do |t|
      t.string :image
      t.text :quote
      t.references :feedback
      t.string :theme

      t.boolean :anomyous, :default => false

      t.timestamps
    end
  end
end
