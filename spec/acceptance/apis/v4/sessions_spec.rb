require 'acceptance_helper'

resource 'Apis::V4::Sessions' do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  post '/apis/v4/sessions/create' do

    parameter :provider, 'Service Type (google, facebook, ect)'
    parameter :code, 'One-time auth code from the service'

    response_field :token, 'MH User Auth Token'

    let(:provider) { 'google' }
    let(:code) { 'asdf' }

    let(:raw_post) { params.to_json }
    example 'logging in' do
      FactoryGirl.create(:person, fb_uid: 123, email: 'test@test.com').create_user!
      stub_request(:get, "https://graph.facebook.com/v2.3/oauth/access_token?client_id=#{ENV['FB_APP_ID']}&client_secret=#{ENV['FB_SECRET']}&code=asdf&redirect_uri=http://localhost:3000/").
          to_return(status: 200, body: '{"access_token":"asedf"}', headers: {})
      stub_request(:get, 'https://graph.facebook.com/v2.3/me?access_token=access_token').
          to_return(status: 200, body: {id:"123"}.to_json, headers: {'Content-Type' => 'application/json'})
      do_request

      expect(status).to be 200
      expect(JSON.parse(response_body)).to include 'token'
    end
  end
end