class SmsKeywordSerializer < ActiveModel::Serializer

  attributes :id, :keyword, :organization_id, :user_id, :explanation,
             :state, :initial_response, :survey_id, :created_at, :updated_at

end

