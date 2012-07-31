class AddDesignFieldsToMhSurveys < ActiveRecord::Migration
  def change
    add_attachment :mh_surveys, :logo
    add_attachment :mh_surveys, :css_file
    change_table :mh_surveys do |t|
      t.text :css
      t.string :background_color
      t.string :text_color
    end
  end
end
