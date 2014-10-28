class AddMoreInfoToSavedVisualTools < ActiveRecord::Migration
  def change
    add_column :saved_visual_tools, :more_info, :text, after: "movement_ids"
  end
end
