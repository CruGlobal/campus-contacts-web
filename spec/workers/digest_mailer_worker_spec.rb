require 'rails_helper'
require 'sidekiq/testing'

describe DigestMailerWorker, '#perform' do
  it 'subscribes users signed in recently' do
    org = create(:organization)
    user1 = create(:user_api, sign_in_count: 1)
    create(:organizational_permission, person: user1.person, organization: org, permission: Permission.admin)
    user2 = create(:user_api, sign_in_count: 1, notification_settings: { "weekly_digest" => true })
    create(:organizational_permission, person: user2.person, organization: org, permission: Permission.admin)
    user3 = create(:user_api, sign_in_count: 1, notification_settings: { "weekly_digest" => false })
    create(:organizational_permission, person: user3.person, organization: org, permission: Permission.admin)

    expect do
      DigestMailerWorker.new.perform
    end.to change(Sidekiq::Extensions::DelayedClass.jobs, :size).by(2)
  end
end
