class DashboardPost < ActiveRecord::Base
  self.table_name = 'mh_dashboard_posts'
  
  attr_accessible :context, :title, :video, :visible
  validates_presence_of :context, :title, :video
  after_create :save_author
  
  def self.current_person
    Thread.current[:current_person]
  end
  
end
