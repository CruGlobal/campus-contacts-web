class DashboardController < ApplicationController
  skip_before_filter :check_all_signatures, only: [:index]

  def index
  end
end
