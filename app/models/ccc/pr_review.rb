class Ccc::PrReview < ActiveRecord::Base
  belongs_to :subject, class_name: "Person"
  belongs_to :initiator, class_name: "Person"
  belongs_to :question_sheet
  has_many :reviewings, class_name: "Ccc::PrReviewer", dependent: :destroy
  has_many :reviewers, through: :reviewings, class_name: "Person", source: :person
  has_one :summary_form
  set_table_name "pr_reviews"

  validates_presence_of :name
  validates_presence_of :due
  validates_presence_of :show_summary_form_days

  default_scope where(fake_deleted: false)

  def self.fake_deleted
    unscoped.where(fake_deleted: true)
  end

  def undelete!
    self.fake_deleted = false
    self.save!
  end

  def has_summary_form
    question_sheet.summary_form.present?
  end

  def name
    self[:name].present? ? self[:name] : question_sheet.label
  end

  def past?
    self.completed_at.present? && self.completed_at < 1.week.ago
  end

  def question_sheets
    [ question_sheet ]
  end
  
  def late?
    Date.today > due && !completed_at
  end

  def rtotal
    reviewings.count
  end

  def rsubmitted
    reviewings.where("submitted_at is not null").count
  end

  def update_percent_and_completed
    submitted = reviewings.where("submitted_at is not null").count
    total = reviewings.count
    logger.info "review #{id}: #{total} reviews, #{submitted} submitted"
    if total > 0
      self.percent = (submitted.to_f / total.to_f * 100).to_i
    else
      self.percent = 0
    end
    if percent == 100
      self.completed_at ||= Time.now
    else
      self.completed_at = nil
    end
    self.save!
  end

  def can_delete?(p)
    return false unless p == self.initiator || p.admin?
    return true if p.admin?
    for reviewing in reviewings
      return false if reviewing.percent_complete.to_i != 0
    end
    return true
  end

  def find_or_create_summary_form
    return summary_form || SummaryForm.create!(person_id: self.subject_id, review_id: self.id)
  end

  def send_day_reminder(template, days_ago)
    if Date.today - due == days_ago
      for reviewing in reviewings
        unless reviewing.submitted_at
          InvitesMailer.reviewer_invite(reviewing, template).deliver
        end
      end
    end
  end

  def send_day_reminders
    send_day_reminder("7 Days Before", 7)
    send_day_reminder("Due Date Today", 0)
  end

  def show_summary_form?
    completed_at? && summary_form.present? && Date.today - due > show_summary_form_days
  end

  def self.send_all_reminders
    Review.where(completed_at: nil).each do |review|
      review.send_day_reminders
    end
  end

  def copy_answers_to(other_review)
    reviewings.each do |reviewing|
      other_reviewing = other_review.reviewings.where(person_id: reviewing.person_id).first
      if other_reviewing
        num_copied = 0
        reviewing.answers.each do |a|
          existing_answer = Answer.where(answer_sheet_id: other_reviewing.id, question_id: a.question_id).first
          unless existing_answer
            a2 = a.clone
            a2.answer_sheet_id = other_reviewing.id
            a2.save!
            num_copied += 1
          end
        end
        puts "#{reviewing.person.full_name}: Found an answer sheet for this person, and copied #{num_copied} of #{reviewing.answers.count} answers over."
      else
        puts "#{reviewing.person.full_name}: Could not find an answer sheet for this person."
      end
    end
  end

end
