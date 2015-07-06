if Rails.env.test?
  require 'webmock/minitest'
  WebMock.disable_net_connect!(allow_localhost: true)
end