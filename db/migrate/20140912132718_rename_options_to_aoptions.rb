#This exists so that I may use adminium to truncate a table on Heroku. Will revert when done.
class RenameOptionsToAoptions < ActiveRecord::Migration
  def change
    rename_table :options, :aoptions
  end
end
