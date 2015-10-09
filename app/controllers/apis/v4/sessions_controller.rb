require 'omniauth_facebook'

class Apis::V4::SessionsController < Apis::V4::BaseController
  skip_before_action :authenticate_user!, only: [:create]

  def create
    user_details, _token = Omniauth::Facebook.authenticate(params[:code])
    user = ::V4::Person.find_by(fb_uid: user_details['id']).try(:user)
    if user
      user.ensure_has_token
      render json: { token: user.token }
    else
      render json: { error: 'Person not found.' }, status: 404
    end
  end
end
