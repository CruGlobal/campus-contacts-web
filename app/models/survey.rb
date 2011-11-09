class Survey < ActiveRecord::Base
  set_table_name 'mh_surveys'
  belongs_to :organization
  has_many :question_sheets, as: :questionnable
  has_many :questions, :through => :question_sheets, :order => 'mh_page_elements.position'
  has_many :archived_questions, :through => :question_sheets
  validates_presence_of :name
  
  
  def question_sheet
    @question_sheet ||= question_sheets.last || question_sheets.create!(label: "Keyword #{id}")
  end
  
  def question_page
    @question_page ||= question_sheet.pages.first || question_sheet.pages.create(number: 1)
  end
end
