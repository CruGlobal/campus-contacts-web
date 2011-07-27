class Admin::SmsKeywordsController < ApplicationController
  def transition
    keyword = SmsKeyword.find(params[:id])
    keyword.send(params[:transition] + '!') if keyword.state_paths.events.include?(params[:transition].to_sym)
    redirect_to '/admin/sms_keywords', notice: "Keyword is now #{keyword.state}"
  end
  
  def approve
    keywords = SmsKeyword.find(params[:bulk_ids])
    keywords.map do |keyword| 
      begin
        SmsKeyword.transaction do
          keyword.approve!
        end
      # rescue StateMachine::InvalidTransition
        
      end
    end
    redirect_to :back
  end
end