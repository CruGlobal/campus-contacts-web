class DashboardPost < ActiveRecord::Base
  
  attr_accessible :context, :title, :video, :visible
  validates_presence_of :context, :title, :video
  
end
