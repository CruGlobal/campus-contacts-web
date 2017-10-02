class AbstractSmsSession < ActiveRecord::Base
  self.abstract_class = true

  attr_accessible :phone_number, :person_id, :interactive, :ended

  belongs_to :person

  validates_presence_of :phone_number, :person_id
end
