class Chart < ActiveRecord::Base
  SNAPSHOT = 'snapshot'

  belongs_to :person
  has_many :chart_organizations
  
  validates_presence_of :person_id, :chart_type
  
  def update_movements(orgs)
    corg_ids = chart_organizations.all.collect(&:organization_id)
    orgs.each do |org|
      unless corg_ids.include?(org.id)
        ChartOrganization.create(chart_id: self.id, organization_id: org.id)
      end
    end
  end
end