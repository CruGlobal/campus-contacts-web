class SurveysController < ApplicationController
  before_filter :prepare_for_mobile
  skip_before_filter :authenticate_user!, except: :start
  skip_before_filter :check_url
  
  require 'api_helper'
  include ApiHelper
   
  def index
    # authenticate_user! unless params[:access_token] && params[:org_id]
    @title = "Pick A Keyword"
    if current_user
      @organization = current_person.organizations.find_by_id(params[:org_id]) || current_organization
      @keywords = @organization ? @organization.keywords : nil
    end
    @keywords ||= SmsKeyword.order('keyword')
    respond_to do |wants|
      wants.html { render layout: 'plain' }
      wants.mobile
    end
  end
  
  def start
    cookies[:survey_mode] = 1
    url = params[:keyword].present? ? contact_form_url(params[:keyword]) : new_user_session_url
    redirect_to facebook_logout_url(next: url)
  end
  
  def stop
    cookies[:survey_mode] = nil
    redirect_to facebook_logout_url
  end

end
