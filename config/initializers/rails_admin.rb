begin
  RailsAdmin.config do |config|
    config.included_models = [Organization, SmsKeyword]
  
    config.model Organization do
      edit do
        field :name
        field :requires_validation
        field :validation_method, :enum
        field :terminology, :enum do
          help "What do you refer to this organization as? i.e. a Ministry, a Movement, etc"
        end
      end
    end
  
    config.model SmsKeyword do
      edit do
        field :keyword
        field :chartfield
        field :explanation
        field :state do
          partial "keyword_state"
        end
      end
      list do
        field :keyword
        field :state
        field :organization
        field :explanation
        field :initial_response
        field :post_survey_message
        field :chartfield
      end
    end
  end
rescue; end