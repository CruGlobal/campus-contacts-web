class PersonPresenter < DelegatePresenter::Base
  def phone_numbers_html
    phone_numbers.order('`primary` desc').collect do |phone_number| 
      s = h(helpers.number_to_phone(phone_number.number))
      s += " (#{I18n.t('general.' + phone_number.location)})" if phone_number.location.present?
      s += '*' if phone_number.primary?
      s
    end.join('<br /> ').html_safe
  end
  
  def email_addresses_html
    email_addresses.order('`primary` desc').collect do |email| 
      s = helpers.mail_to(email)
      s += '*' if email.primary?
      s
    end.join('<br /> ').html_safe
  end
end