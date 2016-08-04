require 'rails_helper'

RSpec.describe TemplatesController, type: :request do
  context 'templates/person.html' do
    it 'should include proper cache header' do
      get '/templates/person.html'
      expect(response).to be_success
      expect(response.headers['Cache-Control']).to include 'public'
      expect(response.headers['Cache-Control']).to include 'max-age=900'
    end
  end
end
