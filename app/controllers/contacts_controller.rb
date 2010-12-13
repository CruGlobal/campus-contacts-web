class ContactsController < ApplicationController
  before_filter :get_person
  
  def new
    sms = ReceivedSms.find_by_id(Base62.decode(params[:received_sms_id])) if params[:received_sms_id]
    @person.update_attribute(:phone_number, sms.phone_number) if sms && sms.phone_number != @person.phone_number
  end
    
  def update
    if @person.update_attributes(params[:person])
      render :thanks
    else
      render :new
    end
  end
  
  def thanks
    
  end
  
  protected
  
    def get_person
      @person = current_user.person
    end
end
