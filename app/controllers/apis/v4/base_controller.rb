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

  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'PUT, POST, GET, OPTIONS, PATCH'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, API-VERSION, Authorization, Content-Type'
    headers['Access-Control-Max-Age'] = '1728000'
    head(:ok) if request.request_method == 'OPTIONS'
  end

  protected

  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'PUT, POST, GET, OPTIONS, PATCH'
    headers['Access-Control-Allow-Headers'] = 'API-VERSION, Authorization, Content-Type'
    headers['Access-Control-Max-Age'] = '1728000'
  end
end
