class RenameFrozenSurvey < ActiveRecord::Migration
  def change
    rename_column :mh_surveys, :frozen, :is_frozen
  end
end
