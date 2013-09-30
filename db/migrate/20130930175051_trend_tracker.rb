class TrendTracker < ActiveRecord::Migration
  def change
    add_column :charts, :trend_all_movements, :boolean, :default => true
    add_column :charts, :trend_start_date, :date
    add_column :charts, :trend_end_date, :date
    add_column :charts, :trend_field_one, :string
    add_column :charts, :trend_field_two, :string
    add_column :charts, :trend_field_three, :string
    add_column :charts, :trend_field_four, :string

    add_column :chart_organizations, :trend_display, :boolean, :default => true
  end
end
