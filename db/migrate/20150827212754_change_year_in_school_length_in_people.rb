class ChangeYearInSchoolLengthInPeople < ActiveRecord::Migration
  def change
    change_column :people, :year_in_school, :string, limit: 50
  end
end
