class SmsKeywordSerializer < ActiveModel::Serializer

  attributes :id, :keyword, :organization_id, :user_id, :explanation,
             :updated_at, :created_at, :state, :initial_response,
             :survey_id

end

