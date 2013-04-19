class RemoveAdvancedOptionsFromSurveys < ActiveRecord::Migration
  def change
    remove_column :elements, :advanced_options
  end
end
