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

  validate do |value|
    if value.for_birth_date_question
      birth_date = value.short_value
      return unless birth_date.present?
      if birth_date =~ /^([1-9]|0[1-9]|1[012])\/([1-9]|0[1-9]|[12][1-9]|3[01])\/(19|2\d)\d\d$/
        begin
          date_str = birth_date.split('/')
          self[:short_value] = Date.parse("#{date_str[2]}-#{date_str[0]}-#{date_str[1]}")
        rescue
          errors.add(:birth_date, "invalid")
        end
      elsif birth_date =~ /^(19|2\d)\d\d\-([1-9]|0[1-9]|1[0-2])\-([1-9]|[012][0-9]|3[01])/
        begin
          self[:short_value] = Date.parse(birth_date.split(' ').first)
        rescue
          errors.add(:birth_date, "invalid")
        end
      elsif birth_date.is_a?(Date)
        self[:short_value] = birth_date
      else
        errors.add(:birth_date, "invalid")
      end
    end
  end

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

  def for_birth_date_question
    return false unless question_id.present? && question = Element.find(question_id)
    question.attribute_name == 'birth_date'
  end

end
