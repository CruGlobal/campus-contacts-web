class BulkMessagesController < ApplicationController
  before_filter :ensure_current_org

  def sms
    authorize! :lead, current_organization

    BulkMessage.perform_async(params[:to], params[:body], current_organization.id, current_person.id)
    render :nothing => true
  end
end
