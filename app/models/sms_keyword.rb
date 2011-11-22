class SmsKeyword < ActiveRecord::Base  
  MOONSHADO_SHORT = '75572'
  SHORT = '85005'
  LONG = '14248886482'
  
  default_value_for :gateway, 'twilio'
  
  enforce_schema_rules  
  
  belongs_to :user
  belongs_to :survey
  has_many :question_sheets, through: :survey
  has_many :questions, :through => :question_sheets, :order => 'mh_page_elements.position'
  has_many :archived_questions, :through => :question_sheets
  
  belongs_to :event, polymorphic: true
  belongs_to :organization
  validates_presence_of :keyword, :explanation, :user_id, :organization_id, :post_survey_message#, :chartfield
  validates_format_of :keyword, with: /^[\w\d]+$/, on: :create, message: "can't have spaces or punctuation"
  validates_uniqueness_of :keyword, on: :create, case_sensitive: false, message: "This keyword has already been taken by someone else. Please choose something else"
  
  state_machine :state, initial: :requested do
    state :requested
    state :active
    state :denied
    state :inactive
    
    event :approve do
      transition [:denied, :requested] => :active
    end
    after_transition :on => :approve, :do => :notify_user
    
    event :deny do
      transition :requested => :denied
    end
    after_transition :on => :deny, :do => :notify_user_of_denial
    
    event :disable do
      transition any => :inactive
    end
    
    event :activate do
      transition :inactive => :active
    end
  end
  
  @queue = :general
  after_create :notify_admin_of_request
  
  def to_s
    keyword
  end
  
  def notify_admin_of_request
    KeywordRequestMailer.enqueue.new_keyword_request(self.id)
  end
  
  def question_page
    @question_page ||= question_sheet.pages.first || question_sheet.pages.create(number: 1)
  end
  
  # def questions
  #   question_sheet.questions
  # end
  
  def keyword_with_state
    "#{keyword} (#{state})"
  end
  
  private
    
    def notify_user
      if user
        KeywordRequestMailer.notify_user(self).deliver
      end
      true
    end
    
    def notify_user_of_denial
      if user
        KeywordRequestMailer.notify_user_of_denial(self).deliver
      end
      true
    end
end
