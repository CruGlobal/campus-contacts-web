class MessagesController < ApplicationController
  def sent_messages
    params[:page] ||= 1
    @messages = current_person.messages_in_org(current_organization.id).includes(:receiver).page(params[:page])
  end
end
