require 'omniauth_facebook'
require 'jwt'

class Apis::V4::SessionsController < Apis::V4::BaseController
  skip_before_action :authenticate_user!, only: [:create]

  def create
    user_details, _token = Omniauth::Facebook.authenticate(params[:code])
    user = ::V4::Person.find_by(fb_uid: user_details['id']).try(:user)
    if user
      payload = { user_id: user.id }
      payload['exp'] = 48.hours.from_now.to_i
      token = JWT.encode(payload, ENV['JSON_WEB_TOKEN_SECRET'], 'HS256')

      render json: { token: token }
    else
      render json: { error: 'Person not found.' }, status: 404
    end
  end
end
