class ChartOrganization < ActiveRecord::Base
  belongs_to :chart
  
  validates_presence_of :chart_id, :organization_id
end