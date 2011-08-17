class MonitorController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :check_su
  skip_before_filter :set_locale
  skip_before_filter :check_url
  
  def up_with_db
    User.first
    render nothing: true
  end
end