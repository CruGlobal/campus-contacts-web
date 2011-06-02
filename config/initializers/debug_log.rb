class DebugLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
  end 
end

module MHDevLogger
  class MHException < Exception
  end

  # Customized logger for the client.
  # This is useful if you're trying to do logging in Rails, since Rails'
  # clean_logger.rb pretty much completely breaks the base Logger class.
  class Logger < ::Logger
    def initialize(logdev, shift_age = 0, shift_size = 1048576)
      @default_formatter = Formatter.new
      super
    end
  
    def format_message(severity, datetime, progrname, msg)
      (@formatter || @default_formatter).call(severity, datetime, progname, msg)
    end
    
    def break
      self << $/
    end
    
    class Formatter < ::Logger::Formatter
      Format = "[%s#%d] %5s -- %s: %s\n"
      
      def call(severity, time, progname, msg)
        Format % [format_datetime(time), $$, severity, progname, msg2str(msg)]
      end
    end
  end

  # Wraps a real Logger. If no real Logger is set, then this wrapper
  # will quietly swallow any logging calls.
  class LoggerWrapper
    def initialize(real_logger=nil)
      set_logger(real_logger)
    end
    # Assign the 'real' Logger instance that this dummy instance wraps around.
    def set_real_logger(real_logger)
      @real_logger = real_logger
    end
    # Log using the appropriate method if we have a logger
    # if we dont' have a logger, gracefully ignore.
    def method_missing(name, *args)
      if @real_logger && @real_logger.respond_to?(name)
        @real_logger.send(name, *args)
      end
    end
  end
end