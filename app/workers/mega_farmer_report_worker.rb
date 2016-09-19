class MegaFarmerReportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(*)
    ReportMailer.all.deliver
    ReportMailer.cru.deliver
    ReportMailer.p2c.deliver
  end
end
