class AddSchoolTypeToEducationHistory < ActiveRecord::Migration
  def change
    add_column :mh_education_history, :school_type, :string
  end
end
