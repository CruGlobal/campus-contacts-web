class AddLoginOptionToSurveys < ActiveRecord::Migration
  def change
    add_column :mh_surveys, :login_option, :integer, :default => 0
  end
end
