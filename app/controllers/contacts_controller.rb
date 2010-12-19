class ContactsController < ApplicationController
  before_filter :get_person
  
  def new
    sms = ReceivedSms.find_by_id(Base62.decode(params[:received_sms_id])) if params[:received_sms_id]
    if sms
      @person.phone_numbers.create!(:number => sms.phone_number, :location => 'mobile') unless @person.phone_numbers.detect {|p| p.number == sms.phone_number}
      sms.update_attribute(:person_id, @person.id) unless sms.person_id
    end
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
