class Jobs::PersonTransferNotifications
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    Batch.person_transfer_notify
  end
end
