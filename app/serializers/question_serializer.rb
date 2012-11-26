class QuestionSerializer < ActiveModel::Serializer

  attributes :id, :kind, :style, :label, :created_at, :updated_at,
             :content, :object_name, :attribute_name, :web_only,
             :trigger_words, :notify_via, :hidden

end

