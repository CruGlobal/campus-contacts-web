class SmsKeyword < ActiveRecord::Base  
  
  belongs_to :user
  validates_presence_of :keyword, :explanation, :user_id#, :chartfield
  validates_format_of :keyword, :with => /^[\w\d]+$/, :on => :create, :message => "can't have spaces or punctuation"
  
  state_machine :state, :initial => :requested do
    state :requested
    state :active
    state :denied
    state :inactive
    
    event :approve do
      transition :requested => :active
    end
    
    event :deny do
      transition :requested => :denied
    end
    
    event :disable do
      transition any => :inactive
    end
  end
  
  @queue = :general
  after_create :queue_notify_admin_of_request
  
  def notify_admin_of_request
    KeywordRequestMailer.new_keyword_request(self).deliver
  end
  
  def self.default
    new(:name => 'Cru', :keyword => 'cru')
  end
  
  private
    def queue_notify_admin_of_request
      async(:notify_admin_of_request) 
      true
    end
end
