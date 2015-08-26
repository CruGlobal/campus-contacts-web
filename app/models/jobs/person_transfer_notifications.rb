class Jobs::PersonTransferNotifications
  include Sidekiq::Worker

  def perform
    Batch.person_transfer_notify
  end
end