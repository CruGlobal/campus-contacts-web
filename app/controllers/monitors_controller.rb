class MonitorsController < ApplicationController
  newrelic_ignore

  skip_before_action :check_valid_subdomain, :authenticate_user!, :clear_advanced_search,
                     :set_login_cookie, :check_su, :set_locale, :check_url, :export_i18n_messages,
                     :set_newrelic_params, :ensure_timezone, :check_mini_profiler, :check_signature,
                     :check_all_signatures

  def lb
    ActiveRecord::Base.connection.select_values('select id from people limit 1')
    render text: 'OK'
  end

  def commit
    render text: ENV['GIT_COMMIT']
  end

  def paper_trail_enabled_for_controller
    false
  end
end
