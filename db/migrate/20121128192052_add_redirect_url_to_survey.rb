class AddRedirectUrlToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :redirect_url, :string, limit: 2000
  end
end
