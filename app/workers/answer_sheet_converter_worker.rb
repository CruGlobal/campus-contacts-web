class AnswerSheetConverterWorker
  include Sidekiq::Worker
  sidekiq_options unique: true, retry: false

  def perform(answer_sheet_id)
    as = AnswerSheet.includes({ person: [:interactions] }, :answers).find_by(id: answer_sheet_id)
    return if as.blank? || as.person.blank? || as.answers.none? || as.existing_note.present?
    note = as.to_note
    note.save! if note.comment_changed?
  end

  def self.batch_perform(days_back, end_date = nil)
    days_back = days_back.days.ago if days_back.to_i < 100
    end_date ||= DateTime.now
    batch = Sidekiq::Batch.new
    batch.description = 'Trying to run a bunch of survey to note conversions.'
    rows = AnswerSheet.where(created_at: days_back..end_date).pluck(:id)
    batch.jobs do
      rows.each { |row| perform_async(row) }
    end
    Rails.logger.log "Just started Batch #{batch.bid}"
  end
end
