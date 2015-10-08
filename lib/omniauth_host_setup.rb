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
      subdomain = @request.subdomain
      if @request.host.include?('mhub')
        OmniAuth.config.full_host = 'https://mhub.cc'
      else
        if subdomain.present? && subdomain != 'www'
          OmniAuth.config.full_host = "https://#{subdomain}.#{ActionMailer::Base.default_url_options[:host]}"
        else
          OmniAuth.config.full_host = 'https://' + ActionMailer::Base.default_url_options[:host]
        end
      end
    end
  end
end
