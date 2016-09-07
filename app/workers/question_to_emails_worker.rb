class AnswerSheetConverterWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(question_id)
    Answer.where(question_id: question_id)
      .includes(answer_sheet: { person: :email_addresses })
      .find_each do |answer|
      email = answer.value.strip
      next if email.blank?
      next unless answer.answer_sheet && answer.answer_sheet.person
      answer.answer_sheet.person.add_email(email)
    end
  end
end
