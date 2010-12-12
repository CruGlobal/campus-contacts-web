class ContactsController < ApplicationController
  def new
    if session[:person_id] #Person.count > 0 #
      @person = Person.find(session[:person_id]) #Person.first #
    else
      @person = Person.new
      code = params['code'] # Facebooks verification string
      if code
        access_token_hash = MiniFB.oauth_access_token(FB_APP_ID, HOST + "contacts/new", FB_SECRET, code)
        @person.access_token = access_token_hash["access_token"]
        @res = MiniFB.get(@person.access_token, 'me')
        @person.email = @res.email
        @person.first_name = @res.first_name
        @person.last_name = @res.last_name
        @person.facebook_uid = @res.id
        @person.gender = @res.gender
        @person.save!
        session[:person_id] = @person.id
      end
    end
  end
    
  def update
    @person = Person.find(session[:person_id]) #Person.first #
    if @person.update_attributes(params[:person])
      render :thanks
    else
      render :new
    end
  end
  
  def create
    @person = Person.new(params[:person])
    if @person.save
      render :thanks
    else
      render :new
    end
  end
  
  def thanks
    
  end
end
