class MovementIndicatorsController < ApplicationController
  def index
  end

  def create
    if current_organization.last_push_to_infobase >= current_organization.last_week
      # don't do anything
    else
      unless current_organization.push_to_infobase(params)
        redirect_to error_movement_indicators_path
        return
      end
    end
  end

  def details
    @interactions = current_organization.interactions_of_type(params[:name]).includes(:receiver).order(:timestamp)
  end
end
