class OmniauthHostSetup
  def self.call(env)
    new(env).setup
  end

  def initialize(env)
    @env = env
    @request = ActionDispatch::Request.new(env)
  end

  def setup
    if Rails.env.production?
      OmniAuth.config.full_host = "https://#{@request.subdomain}.#{ActionMailer::Base.default_url_options[:host]}"
    end
  end
end