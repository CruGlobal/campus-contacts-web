class Survey < ActiveRecord::Base
  set_table_name 'mh_surveys'
  belongs_to :organization, dependent: :destroy
  
  has_many :survey_elements, :dependent => :destroy, :order => :position
  has_many :elements, :through => :survey_elements, :order => SurveyElement.table_name + '.position'
  has_many :question_grid_with_totals, :through => :survey_elements, :conditions => "kind = 'QuestionGridWithTotal'", :source => :element
  has_many :questions, :through => :survey_elements, :source => :question, :order => 'position', :conditions => "#{SurveyElement.table_name}.archived = 0", :order => "#{SurveyElement.table_name}.position"
  has_many :archived_questions, :through => :survey_elements, :source => :question, :order => 'position', :conditions => "#{SurveyElement.table_name}.archived = 1", :order => "#{SurveyElement.table_name}.position"
  has_many :all_questions, :through => :survey_elements, :source => :question, :order => 'position', :order => "#{SurveyElement.table_name}.position"
  has_many :question_grids, :through => :survey_elements, :conditions => "kind = 'QuestionGrid'", :source => :element
  
  # validation
  validates_presence_of :title, :post_survey_message
  validates_length_of :title, :maximum => 100, :allow_nil => true
  
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
  
end
