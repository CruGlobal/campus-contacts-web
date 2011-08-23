require 'csv'
class PeopleController < ApplicationController
  before_filter :ensure_current_org
  before_filter :authorize_merge, only: [:merge, :confirm_merge, :do_merge, :merge_preview]
  before_filter :authorize_merge
  # GET /people
  # GET /people.xml
  def index
    org_ids = params[:subs] == 'true' ? current_organization.self_and_children_ids : current_organization.id
    @people_scope = Person.where('organizational_roles.organization_id' => org_ids).includes(:organizational_roles)
    @q = @people_scope.includes(:primary_phone_number, :primary_email_address)
    @q = @q.where('organizational_roles.role_id' => params[:role_id]) if params[:role_id]
    @q = @q.search(params[:q])
    @q.sorts = ['lastName asc', 'firstName asc'] if @q.sorts.empty?
    @all_people = @q.result(distinct: true)
    @people = @all_people.page(params[:page])
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render xml: @people }
    # end
  end
  
  def export
    index
    out = ""
    CSV.generate(out) do |rows|
      rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('people.index.gender'), t('people.index.email'), t('people.index.phone'), t('people.index.year_in_school')]
      @all_people.each do |person|
        rows << [person.firstName, person.lastName, person.gender, person.email, person.pretty_phone_number, person.yearInSchool]
      end
    end
    filename = current_organization.to_s
    filename += " - #{Role.find_by_id(params[:role_id]).to_s.pluralize}" if params[:role_id].present?
    send_data(out, :filename => "#{filename}.csv", :type => 'application/csv' )
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
  
  def search_ids
    @people = Person.search_by_name(params[:q])
    respond_to do |wants|
      wants.json { render text: @people.collect(&:id).to_json }
    end
  end
  
  def merge
    @people = 1.upto(4).collect {|i| Person.find_by_personID(params["person#{i}"]) if params["person#{i}"].present?}.compact
  end
  
  def confirm_merge
    @people = 1.upto(4).collect {|i| Person.find_by_personID(params["person#{i}"]) if params["person#{i}"].present?}.compact
    unless @people.length >= 2
      redirect_to merge_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "You must select at least 2 people to merge"
      return false
    end
    @keep = @people.delete_at(params[:keep].to_i)
    unless @keep
      redirect_to merge_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "You must specify which person to keep"
      return false
    end
    # If any of the other people have users, the keeper has to have a user
    unless @keep.user
      if person = @people.detect(&:user)
        redirect_to merge_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "Person ID# #{person.id} has a user record, but the person you are trying to keep doesn't. You should keep the record with a user."
        return false
      end
    end
        
  end
  
  def merge_preview
    render nothing and return false unless params[:id].to_i > 0
    @person = Person.find_by_personID(params[:id])
    respond_to do |wants|
      wants.js {  }
    end
  end
  
  def do_merge
    @keep = Person.find(params[:keep_id])
    params[:merge_ids].each do |id|
      person = Person.find(id)
      if @keep.user && person.user
        @keep.user.merge(person.user)
      else
        @keep.merge(person)
      end
    end
    redirect_to merge_people_path, notice: "You've just merged #{params[:merge_ids].length + 1} people"
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
  
  protected
    
    def authorize_read
      authorize! :read, Person
    end
    
    def authorize_merge
      authorize! :merge, Person
    end

end
