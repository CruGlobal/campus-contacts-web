class MovementIndicatorsController < ApplicationController
  def index
  end

  def create
    if current_organization.last_push_to_infobase >= current_organization.last_week
      # don't do anything
    else
      current_organization.push_to_infobase(params)
    end
  end

  def details
    @interactions = current_organization.interactions_of_type(params[:name]).includes(:creator).order(:created_at)
  end
end
