class ChangeBlockOrderNotNull < ActiveRecord::Migration
  def change
    change_column_null :blocks, :order, false, default = 0 
  end
end
