class SurveysController < ApplicationController
  before_filter :set_keyword_cookie, only: :start
  before_filter :prepare_for_mobile
  skip_before_filter :authenticate_user!
  skip_before_filter :check_url
  load_and_authorize_resource except: [:start, :stop]
  
  require 'api_helper'
  include ApiHelper
   
  def index
    # authenticate_user! unless params[:access_token] && params[:org_id]
    if mhub?
      @title = "Pick A Survey"
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
    unless mhub? #|| Rails.env.test?
      redirect_to start_survey_url(params.merge(host: APP_CONFIG['public_host'], port: APP_CONFIG['public_port']))
      return false
    end
    cookies[:survey_mode] = 1
    redirect_to sign_out_url(next: short_survey_url(@survey.id))
  end
  
  # Exit survey mode
  def stop
    cookies[:survey_mode] = nil
    cookies[:keyword] = nil
    cookies[:survey_id] = nil
    redirect_to sign_out_url
  end
  
    
end
