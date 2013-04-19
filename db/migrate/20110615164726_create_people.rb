class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :accountNo
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :gender
      t.string :campus
      t.string :year_in_school
      t.string :major
      t.string :minor
      t.string :greek_affiliation
      t.integer  :user_id
      t.date   :birth_date
      t.date   :date_became_christian
      t.date   :graduation_date
      t.string :level_of_school
      t.string :staff_notes
      t.integer  :primary_campus_involvement_id
      t.integer  :mentor_id
      t.datetime :date_attributes_updated
      t.integer  :crs_profile_id
      t.integer  :sp_person_id
      t.integer  :si_person_id
      t.integer  :pr_person_id
      t.timestamps
    end
  end
end
