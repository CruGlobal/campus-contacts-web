require 'acceptance_helper'

resource 'Apis::V4::Sessions' do
  header "Accept", "application/json"
  header "Content-Type", "application/json"
  get '/apis/v4/sessions/new' do
    parameter :type, 'google'
    parameter :token, 'asdf'

    response_field :auth_token, 'User Auth Token'

    example 'logging in' do
      do_request

      status.should == 200
    end
  end
end