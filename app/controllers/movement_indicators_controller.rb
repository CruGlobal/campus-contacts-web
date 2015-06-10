class MovementIndicatorsController < ApplicationController
  def index
    begin
      resp = RestClient.get(ENV.fetch('INFOBASE_URL') + "/statistics/activity?activity_id=#{current_organization.importable_id}&begin_date=#{Date.today - 3.years}&end_date=#{Date.today}", content_type: :json, accept: :json, authorization: "Bearer #{ENV.fetch('INFOBASE_TOKEN')}")
      json = JSON.parse(resp)
    rescue
      if resp.present?
        raise resp.inspect
      else
        raise "Could not connect to infobase."
      end
    end

    @stats = json["statistics"].last
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
