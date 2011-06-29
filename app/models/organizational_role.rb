class OrganizationalRole < ActiveRecord::Base
  belongs_to :person
  belongs_to :role
  belongs_to :organization
  scope :leaders, where(role_id: Role.leader_ids)
  scope :active, where(deleted: false)
  before_create :set_start_date
  after_save :set_end_date_if_deleted
  
  private
    def set_start_date
      self.start_date = Date.today
    end
    
    def set_end_date_if_deleted
      if changed.include?('deleted') && deleted?
        udpate_attribute(:end_date, Date.today)
      end
    end
end
