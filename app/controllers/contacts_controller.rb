class ContactsController < ApplicationController
  before_filter :get_person
  before_filter :get_keyword, :only => [:new, :update, :thanks]
  
  def new
    if params[:received_sms_id]
      sms = ReceivedSms.find_by_id(Base62.decode(params[:received_sms_id])) 
      if sms
        @keyword ||= SmsKeyword.where(:keyword => sms.message).first
        @person.phone_numbers.create!(:number => sms.phone_number, :location => 'mobile') unless @person.phone_numbers.detect {|p| p.number_with_country_code == sms.phone_number}
        sms.update_attribute(:person_id, @person.id) unless sms.person_id
      end
    end
    get_answer_sheet
  end
    
  def update
    get_answer_sheet
    @person.update_attributes(params[:person]) if params[:person]
    question_set = QuestionSet.new(@keyword.questions, @answer_sheet)
    question_set.post(params[:answers], @answer_sheet)
    question_set.save
    if @person.valid?
      render :thanks
    else
      render :new
    end
  end
  
  def thanks
  end
  
  protected
    
    def get_keyword
      @keyword = SmsKeyword.where(:keyword => params[:keyword]).first if params[:keyword]
    end
    
    def get_person
      @person = current_user.person
    end
    
    def get_answer_sheet
      @answer_sheet = AnswerSheet.where(:person_id => @person.id, :question_sheet_id => @keyword.question_sheet.id).first || 
                      AnswerSheet.create!(:person_id => @person.id, :question_sheet_id => @keyword.question_sheet.id)
    end
end
