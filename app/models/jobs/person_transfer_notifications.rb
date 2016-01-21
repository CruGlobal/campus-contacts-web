class Jobs::PersonTransferNotifications
  include Sidekiq::Worker
  sidekiq_options unique: true, retry: false

  def perform
    Batch.person_transfer_notify
  end
end
