class QuestionLeader < ActiveRecord::Base
  belongs_to :element
  belongs_to :person
end
