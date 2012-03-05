class AddDateAttributesUpdatedToMinistryPerson < ActiveRecord::Migration
  def change
    add_column :ministry_person, :date_attributes_updated, :datetime
  end
end
