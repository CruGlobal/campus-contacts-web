class SavedContactSearchesController < ApplicationController
  def index
  end

  def create
    SavedContactSearch.create(:name => params[:saved_contact_search][:name], :full_path => params[:full_path], :user_id => params[:user_id])
    redirect_to params[:full_path]
  end

  def show
  end

  def edit
  end

  def update
    SavedContactSearch.find(params[:id]).update_attributes(:name => params[:saved_contact_search][:name])
    redirect_to params[:full_path]
  end

  def destroy
  end

end
