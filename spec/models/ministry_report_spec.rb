require 'rails_helper'

describe MinistryReport, versioning: true do
  include ActiveSupport::Testing::TimeHelpers

  let(:person) { create(:person) }

  let(:parent_org) { create(:organization) }
  let(:org1) { create(:organization, parent: parent_org) }
  let(:org2) { create(:organization) }
  let(:org3) { create(:organization) }

  let(:admin_label) { Label.find_by(i18n: 'admin') }
  let(:leader_label) { Label.find_by(i18n: 'leader') }

  describe '#status_changed_count' do
    before(:each) do
      FactoryGirl.create(:organizational_permission, organization: org1, person: person,
                                                     permission_id: 1, followup_status: 'uncontacted')
        .update(followup_status: 'contacted')
      FactoryGirl.create(:organizational_permission, organization: org2, person: person,
                                                     permission_id: 1, followup_status: nil)
        .update(followup_status: 'contacted')
      FactoryGirl.create(:organizational_permission, organization: org3, person: person,
                                                     permission_id: 1, followup_status: 'attempted_contact')
        .update(followup_status: 'contacted')
    end

    it 'counts all' do
      expect(MinistryReport.new(1.hour.ago, 1.second.from_now).status_changed_count).to be 2
    end

    it 'counts sub-orgs' do
      expect(MinistryReport.new(1.hour.ago, 1.second.from_now, parent_org).status_changed_count).to be 1
    end
  end

  describe '#new_contacts' do
    before(:each) do
      [org1, org2, org3].each { |org| create(:organizational_permission, organization: org, person: person) }
    end

    it 'counts all' do
      expect(MinistryReport.new(1.hour.ago, 1.second.from_now).new_contacts).to be 1
    end

    it 'counts sub-orgs' do
      expect(MinistryReport.new(1.hour.ago, 1.second.from_now, parent_org).new_contacts).to be 1
      expect(MinistryReport.new(1.hour.ago, 1.second.from_now, create(:organization)).new_contacts).to be 0
    end
  end

  describe '#interaction_counts' do
    before(:each) do
      receiver1 = create(:person)
      receiver2 = create(:person)
      initiator = create(:person)
      2.times do
        create(:interaction, receiver: receiver1, initiators: [person], creator: person, organization: org1,
                             interaction_type_id: InteractionType::SPIRITUAL_CONVERSATION)
      end
      create(:interaction, receiver: receiver2, initiators: [initiator], creator: person, organization: org1,
                           interaction_type_id: InteractionType::SPIRITUAL_CONVERSATION)

      2.times do
        create(:interaction, receiver: nil, initiators: [person], creator: person, organization: org2,
                             interaction_type_id: InteractionType::SPIRITUAL_CONVERSATION)
      end
    end

    it 'counts all' do
      counts = MinistryReport.new(1.hour.ago, 1.second.from_now).interaction_counts

      expect(counts['Spiritual Conversation']).to include(total: 5, receivers: 4, initiators: 2)
    end

    it 'counts sub-orgs' do
      counts = MinistryReport.new(1.hour.ago, 1.second.from_now, parent_org).interaction_counts

      expect(counts['Spiritual Conversation']).to include(total: 3, receivers: 2, initiators: 2)
    end
  end

  describe '#number_of_people_with_label' do
    before(:each) do
      create(:organizational_permission, organization: parent_org, person: person,
                                         permission_id: 1)
      create(:organizational_label, label: admin_label, person: person, organization: parent_org)

      create(:organizational_permission, organization: org1, person: person,
                                         permission_id: 1)
      create(:organizational_label, label: admin_label, person: person, organization: org1)

      p2 = create(:organizational_label, label: admin_label, organization: org1).person
      create(:organizational_permission, organization: org1, person: p2, permission_id: 1)

      p3 = create(:organizational_label, label: admin_label, organization: org1).person
      create(:organizational_permission, organization: org1, person: p3, permission_id: 1,
                                         archive_date: 1.year.ago)

      p4 = create(:organizational_label, label: admin_label, organization: org1, removed_date: 1.year.ago).person
      create(:organizational_permission, organization: org1, person: p4, permission_id: 1)

      p5 = create(:organizational_label, label: leader_label, organization: org1).person
      create(:organizational_permission, organization: org1, person: p5, permission_id: 1)
    end

    it 'counts all' do
      counts = MinistryReport.new(1.hour.ago, 1.second.ago).number_of_people_with_label(admin_label)

      expect(counts[admin_label.name]).to be 2
    end
  end

  describe '#gained_label' do
    before(:each) do
      create(:organizational_label, label: admin_label, person: person, organization: parent_org)
      create(:organizational_label, label: admin_label, person: person, organization: org1)
      create(:organizational_label, label: admin_label, organization: org1)
      create(:organizational_label, label: leader_label, organization: org1)

      travel_to 1.year.ago do
        create(:organizational_label, label: leader_label, organization: org1)
      end
    end

    it 'counts new admins' do
      counts = MinistryReport.new(1.hour.ago, 1.second.from_now).gained_label(admin_label)

      expect(counts[admin_label.name]).to be 2
    end
  end
end
