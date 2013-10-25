class TrendTracker < ActiveRecord::Migration
  def change
    add_column :charts, :trend_all_movements, :boolean, :default => true
    add_column :charts, :trend_start_date, :date
    add_column :charts, :trend_end_date, :date
    add_column :charts, :trend_field_1, :string
    add_column :charts, :trend_field_2, :string
    add_column :charts, :trend_field_3, :string
    add_column :charts, :trend_field_4, :string
    add_column :charts, :trend_compare_year_ago, :boolean, :default => false

    add_column :chart_organizations, :trend_display, :boolean, :default => true
  end
end
