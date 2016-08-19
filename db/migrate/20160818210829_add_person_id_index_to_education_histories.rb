class AddPersonIdIndexToEducationHistories < ActiveRecord::Migration
  def change
    add_index :education_histories, :person_id
  end
end
