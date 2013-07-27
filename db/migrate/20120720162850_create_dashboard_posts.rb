class CreateDashboardPosts < ActiveRecord::Migration
  def change
    create_table :mh_dashboard_posts do |t|
      t.string :title, default: ""
      t.text :context
      t.string :video, default: ""
      t.boolean :visible, default: 1

      t.timestamps
    end
  end
end
