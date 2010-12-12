unless defined?(OFFLINE)
  OFFLINE = Rack::Offline.configure do
    cache "jqtouch/jqtouch.min.css"
    cache "jqtouch/themes/apple/theme.min.css"
    cache "jqtouch/jquery.1.3.2.min.js"
    cache "jqtouch/jqtouch.min.js"
    cache "javascripts/mobile"
    cache "images/login-button.png"

    network "/"
  end
end