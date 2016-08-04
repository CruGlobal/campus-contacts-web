class TemplatesController < ApplicationController
  # skip all the before actions because we are only serving up plain old html that doesn't need
  # contextualization or protection
  skip_before_action :check_valid_subdomain, :authenticate_user!, :clear_advanced_search,
                     :set_login_cookie, :check_su, :set_locale, :check_url, :export_i18n_messages,
                     :set_newrelic_params, :ensure_timezone, :check_signature, :check_all_signatures

  def template
    expires_in 15.minutes, public: true unless Rails.env.development?
    render template: 'angular/' + params[:path], layout: false
  end
end
