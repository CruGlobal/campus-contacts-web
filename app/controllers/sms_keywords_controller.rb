class SmsKeywordsController < ApplicationController
  before_filter :check_org, :only => [:new]

  def index
    @sms_keywords = current_user.sms_keywords
  end
  # GET /sms_keywords/1
  # GET /sms_keywords/1.xml
  def show
    @sms_keyword = current_user.sms_keywords.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sms_keyword }
    end
  end

  # GET /sms_keywords/new
  # GET /sms_keywords/new.xml
  def new
    session[:wizard] = true if request.referer.present? && request.referer.include?('wizard')
    @sms_keyword = SmsKeyword.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sms_keyword }
    end
  end

  # GET /sms_keywords/1/edit
  def edit
    @sms_keyword = current_user.sms_keywords.find(params[:id])
  end

  # POST /sms_keywords
  # POST /sms_keywords.xml
  def create
    @sms_keyword = current_user.sms_keywords.new(params[:sms_keyword])
    @sms_keyword.user = current_user

    respond_to do |format|
      if @sms_keyword.save
        format.html { redirect_to(session[:wizard] ? wizard_path : user_root_path, :notice => t('ma.keywords.flash.created')) }
        format.xml  { render :xml => @sms_keyword, :status => :created, :location => @sms_keyword }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sms_keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sms_keywords/1
  # PUT /sms_keywords/1.xml
  def update
    @sms_keyword = current_user.sms_keywords.find(params[:id])

    respond_to do |format|
      if @sms_keyword.update_attributes(params[:sms_keyword])
        format.html { redirect_to(root_path, :notice => t('ma.keywords.flash.updated')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sms_keyword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sms_keywords/1
  # DELETE /sms_keywords/1.xml
  def destroy
    @sms_keyword = current_user.sms_keywords.find(params[:id])
    @sms_keyword.destroy

    respond_to do |format|
      format.html { redirect_to user_root_path, :notice => "Keyword has been deleted." }
      format.xml  { head :ok }
    end
  end
  
  private
    def check_org
      unless current_person.primary_organization
        session[:return_to] = params
        redirect_to person_organization_memberships_path(current_person), :notice => t('ma.keywords.flash.pick_org')
        return false
      end
    end
end
