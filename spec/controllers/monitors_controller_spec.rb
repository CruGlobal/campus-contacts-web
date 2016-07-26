# frozen_string_literal: true
require 'spec_helper'

describe MonitorsController do
  context '#lb' do
    it 'gives success because we have a valid database connection' do
      get :lb
      expect(response).to be_success
    end
  end

  context '#commit' do
    it 'renders git GIT_COMMIT env var' do
      ENV['GIT_COMMIT'] = 'abc123'

      get :commit

      expect(response.body).to eq 'abc123'
    end
  end
end
