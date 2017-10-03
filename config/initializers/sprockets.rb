require 'sprockets/glob'
Rails.application.assets.register_processor('application/javascript', Sprockets::Glob::DirectiveProcessor)
