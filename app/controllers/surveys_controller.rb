class SurveysController < ApplicationController
  before_filter :prepare_for_mobile
  skip_before_filter :authenticate_user!
  require 'api_helper'
  include ApiHelper
   
  def index
    authenticate_user! unless params[:access_token] && params[:org_id]
    
    @title = "Pick A Keyword"
    @organization = params[:org_id].present? ? Organization.find(params[:org_id]) : current_organization
    @keywords = @organization.keywords
    @person = try(:current_user).nil? ? get_me : current_person
  end

end
