class TemplatesController < ApplicationController
  def template
    expires_in 15.minutes, public: true if Rails.env.production? || Rails.env.staging?
    render template: 'angular/' + params[:path], layout: false
  end
end
