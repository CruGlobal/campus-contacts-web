class MovementIndicatorSuggestionsController < ApplicationController
  def index
    
  end

  def fetch_suggestions
    @suggestions = MovementIndicatorSuggestion.fetch_active(current_organization)
  end

  def fetch_declined_suggestions
    @suggestions = MovementIndicatorSuggestion.fetch_declined(current_organization)
  end

end
