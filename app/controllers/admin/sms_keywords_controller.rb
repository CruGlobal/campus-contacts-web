class Admin::SmsKeywordsController < ApplicationController
  def transition
    keyword = SmsKeyword.find(params[:id])
    keyword.send(params[:transition] + '!') if keyword.state_paths.events.include?(params[:transition].to_sym)
    redirect_to '/admin/sms_keywords', notice: "Keyword is now #{keyword.state}"
  end
end