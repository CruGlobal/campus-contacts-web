class MegaFarmerReportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(*)
    ReportMailer.all.deliver_later!
    ReportMailer.cru.deliver_later!
    ReportMailer.p2c.deliver_later!
  end
end
