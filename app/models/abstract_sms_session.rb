class AbstractSmsSession < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :person
end
