class DashboardController < ApplicationController
  def index
    @dashpost = DashboardPost.where(visible: true).last
  end
end
