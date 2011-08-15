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
    else
      render_404
    end
    respond_to do |wants|
      wants.html { render layout: 'plain' }
      wants.mobile
    end
  end
  
  def start
    render_404 unless params[:keyword].present?
    cookies[:survey_mode] = 1
    redirect_to facebook_logout_url(next: contact_form_url(params[:keyword], host: 'mhub.cc'))
  end
  
  def stop
    cookies[:survey_mode] = nil
    redirect_to facebook_logout_url
  end

end
