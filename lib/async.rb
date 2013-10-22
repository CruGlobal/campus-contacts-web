module Async

  # This will be called by a worker when a job needs to be processed
  def perform(id, method, *args)
    begin
      if id
        begin
          self.class.find(id).send(method, *args)
        rescue ActiveRecord::RecordNotFound
          # If the record isn't in the db, there's not much we can do
        end
      else
        send(method, *args)
      end
    rescue => e
      Airbrake.notify(e)
      raise
    end
  end

  # We can pass this any Repository instance method that we want to
  # run later.
  def async(method, *args)
    Sidekiq::Client.enqueue(self.class, id, method, *args)
  end

end