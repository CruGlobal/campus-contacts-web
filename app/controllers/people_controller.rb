class PeopleController < ApplicationController
  # GET /people
  # GET /people.xml
  def index
    case
    when params[:keyword]
      return unless set_up_for_keyword
    end
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end
  
  # POST /people
  # POST /people.xml
  # def create
  #   @person = Person.new(params[:person])
  # 
  #   respond_to do |format|
  #     if @person.save
  #       format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
  #       format.xml  { render :xml => @person, :status => :created, :location => @person }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /people/1
  # PUT /people/1.xml
  # def update
  #   @person = Person.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @person.update_attributes(params[:person])
  #       format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # DELETE /people/1
  # # DELETE /people/1.xml
  # def destroy
  #   @person = Person.find(params[:id])
  #   @person.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(people_url) }
  #     format.xml  { head :ok }
  #   end
  # end
  
  def set_up_for_keyword
    @keyword = SmsKeyword.find_by_id(params[:keyword])
    redirect_to user_root_path, error: "The url you just tried to go to wasn't valid." and return false unless @keyword
    @question_sheet = @keyword.question_sheet
    @organization = @keyword.organization
    @people = Person.who_answered(@question_sheet)
    if params[:assigned_to]
      if params[:assigned_to] == 'none'
        @people = unassigned_people
      else
        @assigned_to = Person.find(params[:assigned_to])
        @people = @people.joins(:assigned_tos).where('contact_assignments.question_sheet_id' => @question_sheet.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
      end
    end
    true
  end
  
  def unassigned_people
    @unassigned_people ||= Person.who_answered(@question_sheet).joins("LEFT OUTER JOIN contact_assignments ON contact_assignments.person_id = #{Person.table_name}.#{Person.primary_key}").where('contact_assignments.question_sheet_id' => @question_sheet.id, 'contact_assignments.question_sheet_id' => nil)
  end
  helper_method :unassigned_people
end
