class AddUrlStoMeme < ActiveRecord::Migration
  def change
    add_column :memes, :fb, :string
    add_column :memes, :twitter, :string
    add_column :memes, :tumblr, :string
    add_column :memes, :imgur, :string
    add_column :memes, :pintrest, :string
    
  end

end
