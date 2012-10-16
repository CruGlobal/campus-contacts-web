class Ccc::PrReviewer < AnswerSheet
  establish_connection :uscm

  before_create :generate_access_key
  self.table_name = "pr_reviewers"
  belongs_to :review, class_name: "Ccc::PrReview"
  belongs_to :person
  validates_uniqueness_of :person_id, scope: [ :review_id ], on: :create

  def complete?
    !submitted_at.nil?
  end

  def question_sheet
    review.question_sheet
  end

  def question_sheets
    [ review.question_sheet ]
  end

  # access key for email link
  def generate_access_key
    self.access_key = md5_class.hexdigest((object_id + Time.now.to_i).to_s)
  end

  def url(base_url = "")
    "#{base_url}/review_codes/#{access_key}"
  end

  def submit!
    self.submitted_at = Date.today
    save!
    review.update_percent_and_completed
  end

  def late?
    review.late? && !self.submitted_at
  end

  def md5_class
    if defined?(MD5) then MD5 elsif defined?(Digest::MD5) then Digest::MD5 end
  end

  def collat_title
    person.full_name
  end

end
