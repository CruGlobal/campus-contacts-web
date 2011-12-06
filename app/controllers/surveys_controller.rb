class SurveysController < ApplicationController
  before_filter :prepare_for_mobile
  skip_before_filter :authenticate_user!#, except: :start
  skip_before_filter :check_url
  load_and_authorize_resource
  
  require 'api_helper'
  include ApiHelper
   
  def index
    # authenticate_user! unless params[:access_token] && params[:org_id]
    if mhub?
      @title = "Pick A Keyword"
      if current_user
        @organization = current_person.organizations.find_by_id(params[:org_id]) || current_organization
        @surveys = @organization ? @organization.self_and_children_surveys : nil
      else
        return render_404
      end
      respond_to do |wants|
        wants.html { render layout: 'mhub' }
        wants.mobile
      end
    else
      @organization = current_person.organizations.find_by_id(params[:org_id]) || current_organization
      @surveys = @organization.surveys
    end
  end
  
  def edit
    
  end
  
  def new
    
  end
  
  def update
    if @survey.update_attributes(params[:survey])
      redirect_to surveys_path
    else
      render :edit
    end
  end
  
  def create
    if @survey = current_organization.surveys.create(params[:survey])
      redirect_to surveys_path
    else
      render :new
    end
  end
  
  # Enter survey mode
  def start
    unless params[:keyword].present? && SmsKeyword.find_by_keyword(params[:keyword])
      cookies[:survey_mode] = nil
      cookies[:keyword] = nil
      render_404 
    end
    cookies[:survey_mode] = 1
    cookies[:keyword] = params[:keyword]
    redirect_to facebook_logout_url(next: contact_form_url(params[:keyword]))
  end
  
  # Exit survey mode
  def stop
    cookies[:survey_mode] = nil
    cookies[:keyword] = nil
    redirect_to facebook_logout_url
  end
  
    
end
