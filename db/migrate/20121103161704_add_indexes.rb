class AddIndexes < ActiveRecord::Migration
  def change
    add_index :elements, :kind
  end
end