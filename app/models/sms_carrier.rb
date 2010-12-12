class SmsCarrier < ActiveRecord::Base
  validates_presence_of :moonshado_name
  
  @queue = :general
  
  after_create :check_for_email
  
  def notify_developers_of_new_carrier
    #TODO send an email to prompt someone to find the sms email for this carrier
  end
  
  private
    def check_for_email
      async(:notify_developers_of_new_carrier) if email.blank?
    end
end
