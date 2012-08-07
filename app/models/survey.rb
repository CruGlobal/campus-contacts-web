class Survey < ActiveRecord::Base
  self.table_name = 'mh_surveys'
  belongs_to :organization
  
  has_many :survey_elements, :dependent => :destroy, :order => :position
  has_many :elements, :through => :survey_elements, :order => SurveyElement.table_name + '.position'
  has_many :question_grid_with_totals, :through => :survey_elements, :conditions => "kind = 'QuestionGridWithTotal'", :source => :element
  has_many :questions, :through => :survey_elements, :source => :question, :order => 'position', :conditions => "#{SurveyElement.table_name}.archived = 0", :order => "#{SurveyElement.table_name}.position"
  has_many :archived_questions, :through => :survey_elements, :source => :question, :order => 'position', :conditions => "#{SurveyElement.table_name}.archived = 1", :order => "#{SurveyElement.table_name}.position"
  has_many :all_questions, :through => :survey_elements, :source => :question, :order => 'position', :order => "#{SurveyElement.table_name}.position"
  has_many :question_grids, :through => :survey_elements, :conditions => "kind = 'QuestionGrid'", :source => :element
  has_one :keyword, :dependent => :nullify
  has_one :keyword, :class_name => "SmsKeyword", :foreign_key => "survey_id", :dependent => :nullify

  has_attached_file :logo, :styles => { :small => "300x" }, s3_credentials: 'config/s3.yml', storage: :s3,
                             path: 'surveys/:attachment/:style/:id/:filename', s3_storage_class: :reduced_redundancy
  has_attached_file :css_file, s3_credentials: 'config/s3.yml', storage: :s3,
                             path: 'surveys/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy
  
  has_many :rules, :through => :survey_elements
  
  # validation
  validates_presence_of :title, :post_survey_message, :terminology
  validates_length_of :title, :maximum => 100, :allow_nil => true
  
  default_value_for :terminology, "Survey"
  
  def to_s
    title
  end
  
  # def questions_before_position(position)
  #   self.elements.where(["#{SurveyElement.table_name}.position < ?", position])
  # end
  
  # Include nested elements
  # def all_elements
  #   (elements + elements.collect(&:all_elements)).flatten
  # end
  
  def question_rules
    question_ids = questions.collect(&:id)
    element_ids = SurveyElement.where(element_id: question_ids).collect(&:id)
    question_rules = QuestionRule.where(survey_element_id: element_ids)
  end
  
  def has_assign_rule(type, id = nil)
    rule_id = Rule.find_by_rule_code('AUTOASSIGN')
    rules = question_rules.where(rule_id: rule_id)
    rules.each do |rule|
      if rule.extra_parameters.present?
        if rule.extra_parameters['type'].downcase == type.downcase
          if id.present?
            if rule.extra_parameters['id'].to_s == id.to_s
              return true
            end
          else
            return true
          end
        end
      end
    end
    return false
  end
  
  def duplicate
    new_survey = Survey.new(self.attributes)
    new_survey.organization_id = organization_id
    new_survey.save(:validate => false)
    self.elements.each do |element|
      if element.reuseable?
        SurveyElement.create(:element => element, :survey => new_survey)
      else
        element.duplicate(new_survey)
      end
    end
  end
  
  private
  
end
