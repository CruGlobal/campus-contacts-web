class Admin::SmsKeywordsController < ApplicationController
  def transition
    keyword = SmsKeyword.find(params[:id])
    keyword.send(params[:transition] + '!') if keyword.state_paths.events.include?(params[:transition].to_sym)
    redirect_to rails_admin_list_path('sms_keyword'), notice: "Keyword is now #{keyword.state}"
  end
end