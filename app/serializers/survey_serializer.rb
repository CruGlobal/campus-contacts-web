class SurveySerializer < ActiveModel::Serializer

  attributes :id, :title, :organization_id, :post_survey_message, :login_paragraph,
             :is_frozen, :updated_at, :created_at

  has_many :questions, :serializer => QuestionSerializer
  has_one :keyword

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    if scope.is_a? Array
      include! :questions if includes.include?('questions')
      include! :keyword if includes.include?('keyword')
    end
  end

  [:questions, :keyword].each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

end

