class SurveySerializer < ActiveModel::Serializer

  attributes :id, :title, :organization_id, :post_survey_message, :login_paragraph,
             :is_frozen, :updated_at, :created_at

  has_many :questions, :serializer => QuestionSerializer
  has_one :keyword

  def include_associations!
    if scope.is_a? Array
      include! :questions if scope.include?('questions')
      include! :keyword if scope.include?('keyword')
    end
  end

end

