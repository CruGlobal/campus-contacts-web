class AddAdvancedOptionsToQuestion < ActiveRecord::Migration
  def change
    add_column :mh_elements, :advanced_options, :boolean, :default => 0
  end
end
