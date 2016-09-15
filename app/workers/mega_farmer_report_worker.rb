class MegaFarmerReportWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  CURRENT_USER_RANGE = 180.days.ago

  def perform(*)
    ReportMailer.all.deliver
    ReportMailer.cru.deliver
    ReportMailer.p2c.deliver
  end
end
