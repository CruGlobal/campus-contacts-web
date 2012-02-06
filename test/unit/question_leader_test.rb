require 'test_helper'

class QuestionLeaderTest < ActiveSupport::TestCase
  should belong_to(:element)
  should belong_to(:person)
end
