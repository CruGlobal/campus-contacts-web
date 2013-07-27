class AddLastIndicatorSuggestionsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :last_indicator_suggestion_at, :datetime
  end
end
