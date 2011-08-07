class ChangeMhLocationToLocations < ActiveRecord::Migration
  def up
    rename_table :mh_location, :mh_locations
    rename_table :mh_interest, :mh_interests
    rename_table :mh_education_history, :mh_education_histories
  end

  def down
    rename_table :mh_locations, :mh_location
    rename_table :mh_interests, :mh_interest
    rename_table :mh_education_histories, :mh_education_history
  end
end