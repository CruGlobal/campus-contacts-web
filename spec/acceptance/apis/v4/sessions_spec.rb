require 'acceptance_helper'

resource 'Apis::V4::Sessions' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/apis/v4/sessions' do
    parameter :provider, 'Service Type (google, facebook, ect)'
    parameter :code, 'One-time auth code from the service'

    response_field :token, 'MH User Auth Token'

    let(:provider) { 'google' }
    let(:code) { 'asdf' }

    let(:raw_post) { params.to_json }
    example 'logging in' do
      person = create(:v4_person)
      person.create_user!
      user = person.user
      stub_request(:get, "https://graph.facebook.com/v2.3/oauth/access_token?client_id=#{ENV['FB_APP_ID']}&client_secret=#{ENV['FB_SECRET']}&code=asdf&redirect_uri=#{ENV['FB_REDIRECT_URI']}")
        .to_return(status: 200, body: '{"access_token":"asedf"}', headers: {})
      stub_request(:get, 'https://graph.facebook.com/v2.3/me?access_token=access_token')
        .to_return(status: 200, body: { id: person.fb_uid }.to_json, headers: { 'Content-Type' => 'application/json' })
      do_request

      expect(status).to be 200
      token = JWT.decode(JSON.parse(response_body)['token'], ENV['JSON_WEB_TOKEN_SECRET'], true, algorithm: 'HS256')[0]['token']
      expect(token).to eq user.token
      expect(token).to_not be nil
    end
  end
end
