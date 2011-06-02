class CreateEducationHistories < ActiveRecord::Migration
  def change
    create_table :mh_education_history do |t|
      t.string :person_id
      t.string :type
      t.string :concentration_id1
      t.string :concentration_name1
      t.string :concentration_id2
      t.string :concentration_name2
      t.string :concentration_id3
      t.string :concentration_name3
      t.string :year_id
      t.string :year_name
      t.string :degree_id
      t.string :degree_name
      t.string :school_id
      t.string :school_name
      t.string :provider

      t.timestamps
    end
  end
end
