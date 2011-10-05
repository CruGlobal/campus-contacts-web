RailsAdmin.config do |config|
  config.included_models = ["Organization", "SmsKeyword"]
  config.total_columns_width = 2000
  config.authorize_with do
    redirect_to root_path unless warden.user.developer?
  end
  
  # config.model User do
  #   # object_label_method {:name_with_keyword_count}
  #   visible false
  #   list do
  #     field :username
  #   end
  # end
  
  config.model Organization do
    object_label_method {:name_with_keyword_count}
    edit do
      field :name do
        edit_partial "organization_field_name"
      end
      field :requires_validation
      field :validation_method, :enum
      field :terminology, :enum do
        help "What do you refer to this organization as? i.e. a Ministry, a Movement, etc"
      end
    end
  end
  
  config.model SmsKeyword do
    object_label_method {:keyword_with_state}
    edit do
      field :keyword
      field :chartfield
      field :explanation
      field :initial_response
      field :post_survey_message
      field :chartfield
      field :state do
        partial "keyword_state"
      end
    end
    list do
      field :keyword
      field :state
      field :user do
        pretty_value do
          value ? value.name_with_keyword_count : ''
        end
      end
      field :organization do
        pretty_value do
          v = bindings[:view]
          [value].flatten.select(&:present?).map do |associated|
            amc = polymorphic? ? RailsAdmin::Config.model(associated) : associated_model_config # perf optimization for non-polymorphic associations
            am = amc.abstract_model
            wording = value.name_with_keyword_count
            can_see = v.authorized?(:show, am, associated)
            can_see ? v.link_to(wording, v.show_path(:model_name => am.to_param, :id => associated.id)) : wording
          end.to_sentence.html_safe
        end
      end
      field :explanation do
        pretty_value do
          value
        end
      end
      field :initial_response do
        pretty_value do
          value
        end
      end
      field :post_survey_message do
        pretty_value do
          value
        end
      end
      # field :chartfield
    end
  end
  # if Rails.env.production?
  #   RailsAdmin::AbstractModel.all_models = nil
  #   RailsAdmin::AbstractModel.all_abstract_models = nil
  #   RailsAdmin::AbstractModel.all # rebuild model arrays
  # end
end
# 
# module RailsAdmin
#   module Config
#     class Model < RailsAdmin::Config::Base
# 
#       # monkey patch to get around stale @excluded instance variable
#       def excluded?
#         !RailsAdmin::AbstractModel.all.map(&:model).include?(abstract_model.model)
#       end
# 
#     end
#   end
# end
