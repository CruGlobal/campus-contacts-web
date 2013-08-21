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
  
  def update_movements_displayed(selections)
    if selections
      chart_organizations.each do |movement|
        movement.snapshot_display = selections.include?(movement.organization_id.to_s)
        movement.save
      end
    else
      chart_organizations.each do |movement|
        movement.snapshot_display = false
        movement.save
      end
    end
  end
  
  def self.evang_range_options
    {
      "Past Week" => 0,
      "Past 1 Month" => 1,
      "Past 3 Months" => 3,
      "Past 6 Months" => 6,
      "Past 1 Year" => 12,
      "Past 2 Years" => 24,
      "Past 3 Years" => 36
    }
  end
  
  def self.laborers_range_options
    {
      "Today" => 0,
      "1 Month Ago" => 1,
      "3 Months Ago" => 3,
      "6 Months Ago" => 6,
      "1 Year Ago" => 12,
      "2 Years Ago" => 24,
      "3 Years Ago" => 36
    }
  end
end