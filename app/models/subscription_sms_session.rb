class SubscriptionSmsSession < AbstractSmsSession
  has_many :subscription_choices

  def create_choices(unsubscribes)
    orgs_str = ''
    unsubscribes.each_with_index do |u, index|
      org = u.organization

      value = index + 1
      orgs_str += "for #{org.name} #{I18n.t('sms.sms_respond_with')} '#{value}'"
      orgs_str += ', ' unless value == unsubscribes.length

      SubscriptionChoice.create!(organization_id: org.id, subscription_sms_session_id: id, value: value)
    end

    orgs_str
  end

  def subscribe(choice)
    subscription_choice = subscription_choices.find_by(value: choice)
    return 'Invalid choice' unless subscription_choice

    SmsUnsubscribe.remove_from_unsubscribe(phone_number, subscription_choice.organization.id)
    update!(ended: true)
    I18n.t('sms.sms_subscribed_with_org', org: subscription_choice.organization)
  end
end
