class PersonPresenter < DelegatePresenter::Base
  def phone_numbers_html
    phone_numbers.order('`primary` desc').select {|pn| pn.number.present?}.collect do |phone_number| 
      s = h(helpers.number_to_phone(phone_number.number))
      s += " (#{I18n.t('general.' + phone_number.location)})" if phone_number.location.present?
      s += helpers.raw('<span class="primarymark"></span>') if phone_number.primary?
      s
    end.join('<br /> ').html_safe
  end
  
  def email_addresses_html
    email_addresses.order('`primary` desc').select {|e| e.email.present?}.collect do |email| 
      s = helpers.mail_to(email.email)
      s += helpers.raw('<span class="primarymark"></span>') if email.primary?
      s
    end.join('<br /> ').html_safe
  end
end