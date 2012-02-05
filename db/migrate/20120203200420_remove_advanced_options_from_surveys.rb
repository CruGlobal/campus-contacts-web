class RemoveAdvancedOptionsFromSurveys < ActiveRecord::Migration
  def change
    remove_column :mh_elements, :advanced_options
  end
end
