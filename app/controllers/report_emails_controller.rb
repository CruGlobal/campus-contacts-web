class ReportEmailsController < ApplicationController
  # This controller was written to test regular emails without having to fire them from the console
  # or wait for each week - S0 10/10/16

  def leader_digest
    DigestMailerWorker.delay.send_digest(current_person.id)
    render text: 'Enqueued', status: :accepted
  end
end
