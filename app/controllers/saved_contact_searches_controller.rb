class SavedContactSearchesController < ApplicationController
  before_action :ensure_current_org
  skip_before_action :clear_advanced_search

  def create
    params[:saved_contact_search][:full_path] = convert_hash_to_url(session[:filters]) if session[:filters].present?
    current_user.saved_contact_searches.create(params[:saved_contact_search]) if params[:saved_contact_search].present?
    redirect_to params[:saved_contact_search][:full_path]
  end

  def update
    @full_path = params[:saved_contact_search][:full_path]
    @saved_contact_search_id = params[:saved_contact_search_id]
    if @saved_contact_search_id.present?
      saved_search = current_user.saved_contact_searches.find(@saved_contact_search_id)
      saved_search.update_attributes(params[:saved_contact_search]) if saved_search
      redirect_to @full_path
    else
      create
    end
  end

  def destroy
    saved_contact_search = current_user.saved_contact_searches.find(params[:id])
    saved_contact_search.destroy
    render nothing: true
  end
end
