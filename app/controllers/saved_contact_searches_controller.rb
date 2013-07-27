class SavedContactSearchesController < ApplicationController
  def index
  end

  def create
    current_user.saved_contact_searches.create(params[:saved_contact_search]) if params[:saved_contact_search].present?
    redirect_to params[:saved_contact_search][:full_path]
  end

  def show
  end

  def edit
  end

  def update
    begin
      current_user.saved_contact_searches.find(params[:saved_contact_search_id]).update_attributes(params[:saved_contact_search])
      redirect_to params[:saved_contact_search][:full_path]
    rescue ActiveRecord::RecordNotFound # meaning, the saved_search has been deleted from the left side bar then the user decided to save it again
      create
    end
  end

  def destroy
    saved_contact_search = SavedContactSearch.find(params[:id])
    saved_contact_search.destroy
    render :nothing => true
  end

end
