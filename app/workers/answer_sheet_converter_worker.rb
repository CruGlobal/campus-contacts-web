class AnswerSheetConverterWorker
  include Sidekiq::Worker
  sidekiq_options unique: true, retry: false

  def perform(answer_sheet_id)
    as = AnswerSheet.includes({ person: [:interactions] }, :answers).find(answer_sheet_id)
    return if as.person.blank? || as.existing_note?
    as.to_note.save!
  end

  def self.batch_perform(days_back)
    batch = Sidekiq::Batch.new
    batch.description = 'Trying to run a bunch of survey to note conversions.'
    rows = AnswerSheet.where('created_at > ?', days_back.days.ago).pluck(:id)
    batch.jobs do
      rows.each { |row| RowWorker.perform_async(row) }
    end
    Rails.logger.log "Just started Batch #{batch.bid}"
  end
end
