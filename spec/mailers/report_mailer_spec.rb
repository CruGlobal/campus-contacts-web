# frozen_string_literal: true
require 'rails_helper'

describe ReportMailer do
  include ActiveSupport::Testing::TimeHelpers

  context '#all' do
    with_versioning do
      it 'sends all report with data' do
        travel_to 2.days.ago do
          person = create(:person)
          receiver = create(:person)
          org1 = create(:organization)
          org2 = create(:organization)
          org3 = create(:organization)
          FactoryGirl.create(:organizational_permission, organization_id: org1, person: person,
                                                         permission_id: 1, followup_status: 'uncontacted')
            .update(followup_status: 'contacted')
          FactoryGirl.create(:organizational_permission, organization_id: org2, person: person,
                                                         permission_id: 1, followup_status: nil)
            .update(followup_status: 'contacted')
          FactoryGirl.create(:organizational_permission, organization_id: org3, person: person,
                                                         permission_id: 1, followup_status: 'attempted_contact')
            .update(followup_status: 'contacted')

          create(:interaction, receiver: receiver, initiators: [person],  creator: person,
                               organization: org1,
                               interaction_type_id: InteractionType::SPIRITUAL_CONVERSATION)

          create(:interaction, receiver: nil, initiators: [person], creator: person, organization: org1,
                               interaction_type_id: InteractionType::SPIRITUAL_CONVERSATION)
        end

        mail = ReportMailer.all
        source = mail.body.parts.first.body

        expect(source).to include '2</strong> contacts changed'
        expect(source).to include '1</strong> new contacts'
        expect(source).to include '1 user had 2 Spiritual Conversations with 2 contacts'
      end
    end
  end

  context '#cru' do
    it 'successfully sends' do
      create(:organization, id: 1)

      expect do
        ReportMailer.cru.body.raw_source
      end.to_not raise_exception
    end
  end

  context '#p2c' do
    it 'successfully sends' do
      create(:organization, id: ENV['POWER_TO_CHANGE_ORG_ID'])

      Label.find_or_create_by(i18n: 'made_decision', organization_id: 0)

      expect do
        ReportMailer.p2c.body.raw_source
      end.to_not raise_exception
    end
  end
end
