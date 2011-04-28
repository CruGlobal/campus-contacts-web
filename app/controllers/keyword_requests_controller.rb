class KeywordRequestsController < ApplicationController
  before_filter :check_org, :only => [:new]
  # GET /keyword_requests
  # GET /keyword_requests.xml
  def index
    @keyword_requests = KeywordRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @keyword_requests }
    end
  end

  # GET /keyword_requests/1
  # GET /keyword_requests/1.xml
  def show
    @keyword_request = KeywordRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @keyword_request }
    end
  end

  # GET /keyword_requests/new
  # GET /keyword_requests/new.xml
  def new
    @keyword_request = KeywordRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @keyword_request }
    end
  end

  # GET /keyword_requests/1/edit
  def edit
    @keyword_request = KeywordRequest.find(params[:id])
  end

  # POST /keyword_requests
  # POST /keyword_requests.xml
  def create
    @keyword_request = KeywordRequest.new(params[:keyword_request])
    @keyword_request.user = current_user

    respond_to do |format|
      if @keyword_request.save
        format.html { redirect_to(@keyword_request, :notice => 'Keyword request was successfully created.') }
        format.xml  { render :xml => @keyword_request, :status => :created, :location => @keyword_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @keyword_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /keyword_requests/1
  # PUT /keyword_requests/1.xml
  def update
    @keyword_request = KeywordRequest.find(params[:id])

    respond_to do |format|
      if @keyword_request.update_attributes(params[:keyword_request])
        format.html { redirect_to(@keyword_request, :notice => 'Keyword request was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @keyword_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /keyword_requests/1
  # DELETE /keyword_requests/1.xml
  def destroy
    @keyword_request = KeywordRequest.find(params[:id])
    @keyword_request.destroy

    respond_to do |format|
      format.html { redirect_to(keyword_requests_url) }
      format.xml  { head :ok }
    end
  end
  
  private
    def check_org
      unless current_person.primary_organization
        session[:return_to] = params
        redirect_to person_organization_memberships_path(current_person), :notice => 'Please pick which organization(s) you are associated with'
        return false
      end
    end
end
