class Apis::V4::BaseController < ApplicationController
  # skip_before_filter :verify_authenticity_token
  skip_before_action :set_login_cookie
  skip_before_action :check_su
  skip_before_action :check_valid_subdomain
  skip_before_action :set_locale
  skip_before_action :check_url
  skip_before_action :check_all_signatures
  skip_before_action :check_signature
  skip_before_action :check_mini_profiler
  skip_before_action :export_i18n_messages
  skip_before_action :clear_advanced_search

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
end
