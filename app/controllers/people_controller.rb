class PeopleController < ApplicationController
  # GET /people
  # GET /people.xml
  def index
    org_ids = params[:subs] == 'true' ? current_organization.self_and_children_ids : current_organization.id
    @people_scope = Person.where('organizational_roles.organization_id' => org_ids).includes(:organizational_roles)
    @q = @people_scope.includes(:primary_phone_number, :primary_email_address).page(params[:page])
    @q = @q.where('organizational_roles.role_id' => params[:role_id]) if params[:role_id]
    @q = @q.search(params[:q])
    @q.sorts = ['lastName asc', 'firstName asc'] if @q.sorts.empty?
    @people = @q.result(distinct: true)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @people }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @person }
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
  #       format.html { redirect_to(@person, notice: 'Person was successfully created.') }
  #       format.xml  { render xml: @person, status: :created, location: @person }
  #     else
  #       format.html { render action: "new" }
  #       format.xml  { render xml: @person.errors, status: :unprocessable_entity }
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
  #       format.html { redirect_to(@person, notice: 'Person was successfully updated.') }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render action: "edit" }
  #       format.xml  { render xml: @person.errors, status: :unprocessable_entity }
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

end
