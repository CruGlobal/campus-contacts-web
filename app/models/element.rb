# Element represents a section, question or content element on the question sheet
class Element < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { organization_id: :organization_id }

  QUESTION_TYPES = %w{TextField ChoiceField DateField StateChooser ReferenceQuestion SchoolPicker AttachmentField PaymentQuestion}
  TEXTFIELD_MATCH = [["Contains","contains"], ["Is Exactly","is_exactly"], ["Does Not Contain","does_not_contain"], ["No Response","is_blank"], ["Any Response","any"]]
  CHOICEFILED_MATCH = [["Match Any","any"], ["Match All","all"]]
  DATEFIELD_MATCH = [["Exact","match"],["Between","between"]]

  self.inheritance_column = :kind

  belongs_to :choice_field, :class_name => "ChoiceField", :foreign_key => "conditional_id"
  has_many :survey_elements, :dependent => :destroy
  has_many :surveys, :through => :survey_elements
  has_many :question_leaders, :dependent => :destroy
  has_many :leaders, through: :question_leaders, source: :person
  has_many :answers, foreign_key: :question_id

  before_validation :set_defaults, :on => :create
  validates_presence_of :kind, :style
  # validates_presence_of :label, :style, :on => :update
  validates_length_of :kind, :style, :maximum => 40, :allow_nil => true
  # validates_length_of :label, :maximum => 255, :allow_nil => true
  # TODO: This needs to get abstracted out to a CustomQuestion class in BOAT
  validates_inclusion_of :kind, :in => %w{Section Paragraph TextField ChoiceField DateField FileField SchoolPicker ProjectPreference StateChooser QuestionGrid QuestionGridWithTotal AttachmentField ReferenceQuestion PaymentQuestion}  # leaf classes

  # HUMANIZED_ATTRIBUTES = {
  #   :slug => "Variable"
  # }
  #
  # def self.human_attrib_name(attr)
  #   HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  # end

  # def has_response?(answer_sheet = nil)
  #   false
  # end

  def predefined?
    object_name.present? && attribute_name.present?
  end
  
  def options
    return nil unless kind == "ChoiceField"
    content.split("\n").map{|x| x.gsub("\r","")}
  end
  
  def options_with_blank
    [""] + options
  end

  def search_survey_people(people, answer, organization, option = TEXTFIELD_MATCH.first[1].underscore, range = nil)
    if range.present?
      date_from = translate_date(range.first())
      date_to = translate_date(range.last())
      answer_sheets = AnswerSheet.where(survey_id: surveys.where(organization_id: organization.id, created_at: date_from..date_to).pluck(:id))
    else
      answer_sheets = AnswerSheet.where(survey_id: surveys.where(organization_id: organization.id).pluck(:id))
    end
    all_people = people.where(id: answer_sheets.collect(&:person_id).uniq)

    if object_name.present? && attribute_name.present? && object_name == "person"
      is_multiple_answers = answer.is_a?(Array)
      if is_multiple_answers
        get_answers = answer

        case attribute_name
        when 'gender'
          get_answers = []
          answer.each do |ans|
            if ans.downcase == "female"
              get_answers << "0"
            elsif ans.downcase == "male"
              get_answers << "1"
            else
              get_answers << ans
            end
          end
        end

        if answer.include?("no_response")
          people = all_people.where("people.#{attribute_name} IN (?) OR
            (people.#{attribute_name} IS NULL OR
            people.#{attribute_name} = '')", get_answers)
        else
          people = all_people.where("people.#{attribute_name} IN (?)", get_answers)
        end
      else
        begin
          answer.strip!
        rescue; end
        option = "is_blank" if answer == "no_response"

        case attribute_name
        when "email"
          all_people = all_people.joins("LEFT JOIN email_addresses ON email_addresses.person_id = people.id")
          query_object = "email_addresses.email"
        when "phone_number"
          all_people = all_people.joins("LEFT JOIN phone_numbers ON phone_numbers.person_id = people.id")
          query_object = "phone_numbers.number"
        when 'address1', 'city', 'state', 'country', 'dorm', 'room', 'zip'
          all_people = all_people.joins("LEFT JOIN addresses ON addresses.person_id = people.id")
          query_object = "addresses.#{attribute_name}"
        else
          query_object = "people.#{attribute_name}"
        end

        if option == "contains"
          people = all_people.where("#{query_object} LIKE ?", "%#{answer}%")
        elsif option == "is_exactly"
          people = all_people.where("#{query_object} = ?", answer)
        elsif option == "does_not_contain"
          people = all_people.where("#{query_object} NOT LIKE ?", "%#{answer}%")
        elsif option == "is_blank"
          people = all_people.where("#{query_object} IS NULL OR #{query_object} = ''")
        elsif option == "is_not_blank"
          people = all_people.where("#{query_object} IS NOT NULL AND #{query_object} <> ''")
        elsif option == "match"
          people = all_people.where("DATE(#{query_object}) = DATE(?)", answer["start"])
        elsif option == "between"
          people = all_people.where("DATE(#{query_object}) >= DATE(?) AND DATE(#{query_object}) <= DATE(?)", answer["start"], answer["end"])
        end
      end
    end
    people
  end

  def search_people_answer_textfield(people, survey, answer, option = TEXTFIELD_MATCH.first[1].underscore, range = nil)
    all_answers = Answer.includes(:answer_sheet).where("answer_sheets.survey_id = ? AND question_id = ?", survey.id, id)
    answer.strip!
    if range.present?
      date_from = translate_date(range.first())
      date_to = translate_date(range.last())
      all_answers = all_answers.where("DATE(created_at) >= DATE(?) AND DATE(created_at) <= DATE(?)", date_from, date_to)
    end

    if ['contains','is_exactly','is_not_blank'].include?(option)
      all_answers = all_answers.includes(:answer_sheet).where('answer_sheets.person_id' => people.collect(&:id))
      if option == "contains"
        valid_answers = all_answers.where("value LIKE ?", "%#{answer}%")
      elsif option == "is_exactly"
        valid_answers = all_answers.where("value = ?", answer)
      elsif option == "is_not_blank"
        valid_answers = all_answers.where("value IS NOT NULL OR value <> ''")
      end
      return people.where(id: valid_answers.includes(:answer_sheet).collect{|x| x.answer_sheet.person_id})
    elsif option == 'any'
      return people.where(id: people.collect(&:id))
    elsif option == 'is_blank'
      valid_answers = all_answers.where("value IS NOT NULL OR value <> ''")
      return people.where("people.id NOT IN (?)", valid_answers.includes(:answer_sheet).collect{|x| x.answer_sheet.person_id})
    elsif option == 'does_not_contain'
      valid_answers = all_answers.where("value LIKE ?", "%#{answer}%")
      return people.where("people.id NOT IN (?)", valid_answers.includes(:answer_sheet).collect{|x| x.answer_sheet.person_id})
    end
  end

  def search_people_answer_choicefield(people, survey, field_answers, option = CHOICEFILED_MATCH.first[1].underscore, range = nil)
    field_answers = field_answers.map{|x| x.downcase.strip}
    all_answers = Answer.includes(:answer_sheet).where("answer_sheets.survey_id = ? AND question_id = ?", survey.id, id)
    if range.present?
      date_from = translate_date(range.first())
      date_to = translate_date(range.last())
      all_answers = all_answers.where("DATE(created_at) >= DATE(?) AND DATE(created_at) <= DATE(?)", date_from, date_to)
    end

    if option == "any"
      if field_answers.include?("no_response")
        field_answers = field_answers.reject { |ans| ans == "no_response" }
        if field_answers.count > 0
          all_answers = all_answers.where("LOWER(value) NOT IN (?)", field_answers)
        end
        person_ids = people.collect(&:id) - all_answers.collect{|x| x.answer_sheet.person_id}
      else
        person_ids = all_answers.where("LOWER(value) IN (?)", field_answers).collect{|x| x.answer_sheet.person_id}
      end
      return people.where(id: person_ids)
    elsif option == "all"
      all_answers = all_answers.includes(:answer_sheet).where('answer_sheets.person_id' => people.collect(&:id))
      field_answers.each do |answer|
        filtered_answers = all_answers.where(value: answer)
        people = people.where(id: filtered_answers.includes(:answer_sheet).collect{|x| x.answer_sheet.person_id})
      end
      return people
    end
  end

  def search_survey_answer_datefield(answer, option = DATEFIELD_MATCH.first[1].underscore, range = nil)
    if range.present?
      date_from = translate_date(range.first())
      date_to = translate_date(range.last())
      all_answers = Answer.where("question_id = ? AND (DATE(created_at) >= DATE(?) AND DATE(created_at) <= DATE(?))", id, date_from, date_to)
    end
    all_answers ||= Answer.where("question_id = ?", id)
    if option == "match"
      answers =  all_answers.where("DATE(value) = DATE(?)", answer["start"])
    elsif option == "between"
      answers =  all_answers.where("DATE(value) >= DATE(?) AND DATE(value) <= DATE(?)", answer["start"], answer["end"])
    end
    return answers
  end

  def organization_id
    surveys.first.try(:organization_id)
  end

  def required?(answer_sheet = nil)
    super()
  end

  def position(survey = nil)
    if survey
      survey_elements.where(:survey_id => survey.id).first.try(:position)
    else
      self[:position]
    end
  end

  # def set_position(position, survey = nil)
  #   if survey
  #     pe = survey_elements.where(:survey_id => survey.id).first
  #     pe.update_attribute(:position, position) if pe
  #   else
  #     self[:position] = position
  #   end
  #   position
  # end

  def question?
    self.kind_of?(Question)
  end


  # by default the partial for an element matches the class name (override as necessary)
  def ptemplate
    self.class.to_s.underscore
  end

  # copy an item and all it's children
  def duplicate(survey, parent = nil)
    new_element = self.class.new(self.attributes)
    case parent.class.to_s
    when ChoiceField
      new_element.conditional_id = parent.id
    when QuestionGrid, QuestionGridWithTotal
      new_element.question_grid_id = parent.id
    end
    new_element.save(:validate => false)
    SurveyElement.create(:element => new_element, :survey => survey) unless parent

    # duplicate children
    if respond_to?(:elements) && elements.present?
      elements.each {|e| e.duplicate(survey, new_element)}
    end

    new_element
  end

  # include nested elements
  # def all_elements
  #   if respond_to?(:elements)
  #     (elements + elements.collect(&:all_elements)).flatten
  #   else
  #     []
  #   end
  # end

  def reuseable?
    (self.is_a?(Question) || self.is_a?(QuestionGrid) || self.is_a?(QuestionGridWithTotal))
  end

  protected
  def set_defaults
    if self.content.blank?
      case self.class.to_s
        when "ChoiceField" then self.content ||= "Choice One\nChoice Two\nChoice Three"
        when "Paragraph" then self.content ||= "Lorem ipsum..."
      end
    end

    if self.style.blank?
      case self.class.to_s
      when 'TextField' then self.style ||= 'essay'
      when "DateField" then self.style ||= "date"
      when "FileField" then self.style ||= "file"
      when "Paragraph" then self.style ||= "paragraph"
      when "Section" then self.style ||= "section"
      when "ChoiceField" then self.style = "checkbox"
      when "QuestionGrid" then self.style ||= "grid"
      when "QuestionGridWithTotal" then self.style ||= "grid_with_total"
      when "SchoolPicker" then self.style ||= "school_picker"
      when "ProjectPreference" then self.style ||= "project_preference"
      when "StateChooser" then self.style ||= "state_chooser"
      when "ReferenceQuestion" then self.style ||= "peer"
      else
        self.style ||= self.class.to_s.underscore
      end
    end
  end

  def translate_date(date)
    begin
      get_date = date.split('/')
      return Date.parse("#{get_date[2]}-#{get_date[0]}-#{get_date[1]}").strftime("%Y-%m-%d")
    rescue
    end
  end

end
