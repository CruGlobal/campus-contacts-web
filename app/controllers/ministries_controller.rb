class MinistriesController < ApplicationController
  skip_before_filter :authenticate_user!  # TEMPORARY!
  # GET /ministries
  # GET /ministries.xml
  def index
    @ministries = Ministry.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ministries }
    end
  end

  # GET /ministries/1
  # GET /ministries/1.xml
  def show
    @ministry = Ministry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ministry }
    end
  end

  # GET /ministries/new
  # GET /ministries/new.xml
  def new
    @ministry = Ministry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ministry }
    end
  end

  # GET /ministries/1/edit
  def edit
    @ministry = Ministry.find(params[:id])
  end

  # POST /ministries
  # POST /ministries.xml
  def create
    @ministry = Ministry.new(params[:ministry])

    respond_to do |format|
      if @ministry.save
        format.html { redirect_to(@ministry, :notice => 'Ministry was successfully created.') }
        format.xml  { render :xml => @ministry, :status => :created, :location => @ministry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ministry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ministries/1
  # PUT /ministries/1.xml
  def update
    @ministry = Ministry.find(params[:id])

    respond_to do |format|
      if @ministry.update_attributes(params[:ministry])
        format.html { redirect_to(@ministry, :notice => 'Ministry was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ministry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ministries/1
  # DELETE /ministries/1.xml
  def destroy
    @ministry = Ministry.find(params[:id])
    @ministry.destroy

    respond_to do |format|
      format.html { redirect_to(ministries_url) }
      format.xml  { head :ok }
    end
  end
end
