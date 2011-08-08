RailsAdmin.config do |config|
  config.included_models = ["Organization", "SmsKeyword"]
  config.total_columns_width = 2000
  config.authorize_with do
    redirect_to root_path unless warden.user.developer?
  end
  # if Rails.env.production?
    RailsAdmin::AbstractModel.all_models = nil
    RailsAdmin::AbstractModel.all_abstract_models = nil
    RailsAdmin::AbstractModel.all # rebuild model arrays
  # end
end

module RailsAdmin
  module Config
    class Model < RailsAdmin::Config::Base

      # monkey patch to get around stale @excluded instance variable
      def excluded?
        !RailsAdmin::AbstractModel.all.map(&:model).include?(abstract_model.model)
      end

    end
  end
end
