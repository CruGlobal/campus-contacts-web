class ReportEmailsController < ApplicationController
  # This controller was written to test regular emails without having to fire them from the console
  # or wait for each week - S0 10/10/16

  def leader_digest
    success = ReportMailer.leader_digest(current_person.id).deliver
    response_text = success ? 'OK' : "Failed to send (perhaps because your orgs didn't have interactions)"
    status = success ? :success : 500
    render text: response_text, status: status
  end
end
