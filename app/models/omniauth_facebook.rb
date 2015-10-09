require 'httparty'

# http://stackoverflow.com/a/30419460/879524
class Omniauth::Facebook
  include HTTParty
  debug_output $stdout

  # The base uri for facebook graph API
  base_uri 'https://graph.facebook.com/v2.3'

  # Used to authenticate app with facebook user
  # Usage
  #   Omniauth::Facebook.authenticate('authorization_code')
  # Flow
  #   Retrieve access_token from authorization_code
  #   Retrieve User_Info hash from access_token
  def self.authenticate(code)
    provider = new
    access_token = provider.get_access_token(code)
    user_info    = provider.get_user_profile(access_token)
    [user_info, access_token]
  end

  # Used to revoke the application permissions and login if a user
  # revoked some of the mandatory permissions required by the application
  # like the email
  # Usage
  #    Omniauth::Facebook.deauthorize('user_id')
  # Flow
  #   Send DELETE /me/permissions?access_token=XXX
  def self.deauthorize(access_token)
    options  = { query: { access_token: access_token } }
    response = delete('/me/permissions', options)

    # Something went wrong most propably beacuse of the connection.
    unless response.success?
      Rails.logger.error 'Omniauth::Facebook.deauthorize Failed'
      fail 'errors.auth.facebook.deauthorization'
    end
    response.parsed_response
  end

  def get_access_token(code)
    response = self.class.get('/oauth/access_token', query(code))

    # Something went wrong either wrong configuration or connection
    unless response.success?
      Rails.logger.error 'error:'
      Rails.logger.error response
      Rails.logger.error 'Omniauth::Facebook.get_access_token Failed'
      fail 'errors.auth.facebook.access_token'
    end
    response.parsed_response['access_token']
  end

  def get_user_profile(access_token)
    options = { query: { access_token: access_token } }
    response = self.class.get('/me', options)

    # Something went wrong most propably beacuse of the connection.
    unless response.success?
      Rails.logger.error 'Omniauth::Facebook.get_user_profile Failed'
      fail 'errors.auth.facebook.user_profile'
    end
    p response
    response.parsed_response
  end

  private

  # access_token required params
  # https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow/v2.3#confirm
  def query(code)
    {
      query: {
        code: code,
        redirect_uri: 'http://localhost:3000/',
        client_id: ENV['FB_APP_ID'],
        client_secret: ENV['FB_SECRET']
      }
    }
  end
end
