class ActiveRecord::Base
    # This will be called by a worker when a job needs to be processed
  def self.perform(id, method, *args)
    begin
      if id
        begin
          find(id).send(method, *args)
        rescue ActiveRecord::RecordNotFound
          # If the record isn't in the db, there's not much we can do
        end
      else
        new.send(method, *args)
      end
    rescue => e
      Airbrake.notify(e)
      raise
    end
  end

  # We can pass this any Repository instance method that we want to
  # run later.
  def async(method, *args)
    Resque.enqueue(self.class, id, method, *args)
  end
end

# if defined?(Mysql2Adapter)
#   module ActiveRecord::ConnectionAdapters
#     class Mysql2Adapter
#       alias_method :execute_without_retry, :execute
#
#       def execute(*args)
#         execute_without_retry(*args)
#       rescue ActiveRecord:StatementInvalid: e
#         if e.message =~ /server has gone away/i
#           warn "Server timed out, retrying"
#           reconnect!
#           retry
#         else
#           raise e
#         end
#       end
#     end
#   end
# end

class ActiveRecord::Base

  def self.create_or_update(relation, attrs_to_update)
    if (incumbent = relation.first).nil?
      relation.create!(attrs_to_update)
    else
      incumbent.update_attributes(attrs_to_update)
      incumbent
    end
  end

end
