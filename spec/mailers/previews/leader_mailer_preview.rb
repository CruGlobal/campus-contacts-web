# frozen_string_literal: true

class LeaderMailerPreview < ActionMailer::Preview
  def added
    p1, p2 = Person.where.not(user_id: nil).first(2)
    organization = Organization.first
    LeaderMailer.added(p1.id, p2.id, organization.id, "testtoken")
  end
end
