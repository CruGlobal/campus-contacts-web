class SentPerson < ActiveRecord::Base
  attr_accessible :person_id, :transferred_by_id
  belongs_to :person
end
