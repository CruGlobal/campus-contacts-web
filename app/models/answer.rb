# Answer
# - a single answer to a given question for a specific answer sheet (instance of capturing answers)
# - there may be multiple answers to a question for "choose many" (checkboxes)

# short value is indexed for finding the value (reporting)
# essay questions have a nil short value
# may want special handling for ChoiceFields to store both id/slug and text representations

class Answer < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { person_id: :person_id }

  belongs_to :answer_sheet, inverse_of: :answers
  belongs_to :question, :class_name => "Element", :foreign_key => "question_id"

#  validates_presence_of :value
  validates_length_of :short_value, :maximum => 255, :allow_nil => true

  before_save :set_value_from_filename


  include ActionView::Helpers::TextHelper   # bleh
  def set(value, short_value = value)
    self.value = value
    self.short_value = truncate(short_value, :length => 225) # adds ... if truncated (but not if not)
    save
  end

  def to_s
    value || ''
  end

  def set_value_from_filename
    self.value = self.short_value = self.attachment_file_name if self[:attachment_file_name].present?
  end
  
  def person_id
    answer_sheet.person_id
  end


end
