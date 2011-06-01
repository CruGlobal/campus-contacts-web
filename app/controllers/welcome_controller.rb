class WelcomeController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :index
  def index
    if user_signed_in?
      redirect_to user_root_path and return
    end
  end

end
