class Apis::V4::SessionsController < Apis::V4::BaseController
  skip_before_filter :authenticate_user!, only: [:new]
  def new
    render json: { auth_token: 'foo' }
  end
end