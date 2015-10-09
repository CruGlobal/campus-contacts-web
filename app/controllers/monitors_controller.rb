class MonitorsController < ApplicationController
  def lb
    ActiveRecord::Base.connection.select_values('select id from people limit 1')
    render text: 'OK'
  end
end
