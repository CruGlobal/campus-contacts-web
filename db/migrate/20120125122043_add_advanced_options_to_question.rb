class AddAdvancedOptionsToQuestion < ActiveRecord::Migration
  def change
    add_column :elements, :advanced_options, :boolean, :default => 0
  end
end
