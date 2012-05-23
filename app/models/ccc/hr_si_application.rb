class Ccc::HrSiApplication < ActiveRecord::Base
  self.primary_key = 'applicationID'
  has_one :tracking, class_name: 'Ccc::SitrackTracking', foreign_key: :application_id, dependent: :destroy
  belongs_to :person, foreign_key: :fk_personID
  belongs_to :si_apply, class_name: 'Ccc::SiApply', foreign_key: :apply_id
end
