require 'spec_helper'

describe RequestAccess do
  context '#save' do
    it 'creates a new person' do
      Person.destroy_all
      request = RequestAccess.new(first_name: 'Nick', last_name: 'Fury', email: 'furry.nick@cru.org', org_name: 'Avengers')

      expect { request.save }.to change(Person, :count).by(1)
        .and change(Organization, :count).by(1)
      org = Organization.last
      expect(org.name).to eq 'Avengers'
      expect(org.admins.first.name).to eq 'Nick Fury'
      expect(org.admins.first.email).to eq 'furry.nick@cru.org'
    end
  end
end
