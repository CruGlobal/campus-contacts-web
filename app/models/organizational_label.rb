class OrganizationalLabel < ActiveRecord::Base
  attr_accessible :added_by_id, :label_id, :organization_id, :person_id, :removed_date, :start_date
  before_create :set_start_date
  
  belongs_to :person, :touch => true
  belongs_to :created_by, class_name: 'Person', foreign_key: 'added_by_id'
  belongs_to :label
  belongs_to :organization
  
  private

    def set_start_date
      self.start_date = Date.today
      true
    end
end
