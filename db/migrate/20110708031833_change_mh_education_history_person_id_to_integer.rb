class ChangeMhEducationHistoryPersonIdToInteger < ActiveRecord::Migration
  def up
	change_column(:mh_education_history, :person_id, :integer)
  end

  def down
	change_column(:mh_education_history, :person_id, :string)
  end
end
