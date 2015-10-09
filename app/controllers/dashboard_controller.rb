class DashboardController < ApplicationController
  skip_before_action :check_all_signatures, only: [:index]

  def index
  end
end
