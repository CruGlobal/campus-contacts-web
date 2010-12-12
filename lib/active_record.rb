class ActiveRecord::Base
    # This will be called by a worker when a job needs to be processed
  def self.perform(id, method, *args)
    if id
      find(id).send(method, *args)
    else
      new.send(method, *args)
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
#       rescue ActiveRecord::StatementInvalid => e
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