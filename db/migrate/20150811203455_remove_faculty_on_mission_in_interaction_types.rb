class RemoveFacultyOnMissionInInteractionTypes < ActiveRecord::Migration
  def change
    interaction_type = InteractionType.find_by(i18n: 'faculty_on_mission', organization_id: 0)
    interaction_type.destroy if interaction_type.present?
  end
end
