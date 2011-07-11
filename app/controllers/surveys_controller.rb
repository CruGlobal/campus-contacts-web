class SurveysController < ApplicationController
  before_filter :prepare_for_mobile
  skip_before_filter :authenticate_user!, only: :index
  require 'api_helper'
  include ApiHelper
   
  def index
    authenticate_user! unless params[:access_token] && params[:org_id]
    
    @title = "Pick A Keyword"
    @organization = params[:org_id].present? ? Organization.find(params[:org_id]) : current_organization
    @keywords = @organization.keywords
    @person = try(:current_user).nil? ? get_me : current_person
  end
  
  def start
    cookies[:survey_mode] = 1
    logger.info cookies[:survey_mode].inspect
    url = contact_form_url(params[:keyword])
    redirect_to url
  end
  
  def stop
    cookies[:survey_mode] = nil
    redirect_to new_user_session_path
  end

end
