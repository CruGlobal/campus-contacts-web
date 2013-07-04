class MovementIndicatorSuggestionsController < ApplicationController
  def index
  end

  def fetch_suggestions
    @suggestions = MovementIndicatorSuggestion.fetch_active(current_organization)
  end

  def fetch_declined_suggestions
    @suggestions = MovementIndicatorSuggestion.fetch_declined(current_organization)
  end

  def update
    @movement_indicator_suggestion = current_organization.movement_indicator_suggestions.find(params[:id])
    @movement_indicator_suggestion.update_attributes(params[:movement_indicator_suggestion])
    respond_to do |wants|
      wants.js { render nothing: true }
    end
  end

end
