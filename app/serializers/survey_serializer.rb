class SurveySerializer < ActiveModel::Serializer
  INCLUDES = [:questions, :all_questions, :archived_questions, :keyword]

  attributes :id, :title, :organization_id, :post_survey_message, :terminology, :login_paragraph,
             :is_frozen, :created_at, :updated_at

  has_many :questions, :serializer => QuestionSerializer
  has_many :all_questions, :serializer => QuestionSerializer
  has_many :archived_questions, :serializer => QuestionSerializer
  has_one :keyword

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      if INCLUDES.include?(rel.to_sym)
        include!(rel.to_sym)
      end
    end if includes
  end
  
  INCLUDES.each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

end

