class AddFrozenToSurvey < ActiveRecord::Migration
  def change
    add_column :mh_surveys, :frozen, :boolean
  end
end
