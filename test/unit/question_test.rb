require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  should belong_to(:related_question_sheet)
  should have_many(:conditions)
  should have_many(:dependents)
  should have_many(:sheet_answers)
end
