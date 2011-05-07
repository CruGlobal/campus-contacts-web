class SmsKeyword < ActiveRecord::Base  belongs_to :user
  validates_presence_of :keyword, :explanation, :user_id#, :chartfield
  validates_format_of :keyword, :with => /^[\w\d]+$/, :on => :create, :message => "can't have spaces or punctuation"
  
  @queue = :general
  after_create :notify_admin_of_request_on_create
  
  def notify_admin_of_request
    KeywordRequestMailer.new_keyword_request(self).deliver
  end
  
  def self.default
    new(:name => 'Cru', :keyword => 'cru')
  end
  
  private
    def notify_admin_of_request_on_create
      async(:notify_admin_of_request) 
    end
end
