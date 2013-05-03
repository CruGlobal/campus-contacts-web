class InteractionsController < ApplicationController
  def show_profile
    @person = Person.find(params[:id])
  end
end
