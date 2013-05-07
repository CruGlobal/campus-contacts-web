require 'test_helper'

class InteractionTest < ActiveSupport::TestCase
  should have_many(:interaction_initiators)
  should have_many(:initiators)
  should belong_to(:organization)
  should belong_to(:interaction_type)
  should belong_to(:receiver)
  should belong_to(:creator)
  
end
