class SmsKeyword < ActiveRecord::Base  
  SHORT = '75572'
  enforce_schema_rules  
  
  belongs_to :user
  has_many :question_sheets, as: :questionnable
  has_many :questions, :through => :question_sheets
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
      transition requested: :active
    end
    after_transition :on => :approve, :do => :notify_user
    
    event :deny do
      transition requested: :denied
    end
    after_transition :on => :deny, :do => :notify_user_of_denial
    
    event :disable do
      transition any => :inactive
    end
  end
  
  @queue = :general
  after_create :queue_notify_admin_of_request
  
  def to_s
    keyword
  end
  
  def question_sheet
    @question_sheet ||= question_sheets.last || question_sheets.create!(label: "Keyword #{id}")
  end
  
  def notify_admin_of_request
    KeywordRequestMailer.new_keyword_request(self).deliver
  end
  
  def question_page
    @question_page ||= question_sheet.pages.first || question_sheet.pages.create(number: 1)
  end
  
  def questions
    question_sheet.questions
  end
  
  def keyword_with_state
    "#{keyword} (#{state})"
  end
  
  rails_admin do
    object_label_method {:keyword_with_state}
    edit do
      field :keyword
      field :chartfield
      field :explanation
      field :initial_response
      field :post_survey_message
      field :chartfield
      field :state do
        partial "keyword_state"
      end
    end
    list do
      field :keyword
      field :state
      field :user do
        pretty_value do
          value.name_with_keyword_count
        end
      end
      field :organization do
        pretty_value do
          v = bindings[:view]
          [value].flatten.select(&:present?).map do |associated|
            amc = polymorphic? ? RailsAdmin::Config.model(associated) : associated_model_config # perf optimization for non-polymorphic associations
            am = amc.abstract_model
            wording = value.name_with_keyword_count
            can_see = v.authorized?(:show, am, associated)
            can_see ? v.link_to(wording, v.show_path(:model_name => am.to_param, :id => associated.id)) : wording
          end.to_sentence.html_safe
        end
      end
      field :explanation
      field :initial_response
      field :post_survey_message
      # field :chartfield
    end
  end
  
  private
    def queue_notify_admin_of_request
      async(:notify_admin_of_request) 
      true
    end
    
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
