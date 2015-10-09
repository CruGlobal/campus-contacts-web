require 'json'

class EmailResponsesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  before_action :log_incoming_message

  def bounce
    return render json: {} unless aws_message.authentic?

    if type != 'Bounce'
      Rails.logger.info 'Not a bounce - exiting'
      return render json: {}
    end

    bounce = message['bounce']
    bouncerecps = bounce['bouncedRecipients']
    bouncerecps.each do |recp|
      email = recp['emailAddress']
      extra_info = "status: #{recp['status']}, action: #{recp['action']}, diagnosticCode: #{recp['diagnosticCode']}"
      Rails.logger.info "Creating a bounce record for #{email}"

      existing = EmailResponse.find_by(email: email)
      if existing
        Rails.logger.info 'Already suppressed'
        return render json: {}
      end

      EmailResponse.create ({ email: email, response_type: 'bounce', extra_info: extra_info })
    end

    render json: {}
  end

  def complaint
    return render json: {} unless aws_message.authentic?

    if type != 'Complaint'
      Rails.logger.info 'Not a complaint - exiting'
      return render json: {}
    end

    complaint = message['complaint']
    recipients = complaint['complainedRecipients']
    recipients.each do |recp|
      email = recp['emailAddress']
      extra_info = "complaintFeedbackType: #{complaint['complaintFeedbackType']}"
      EmailResponse.create ( { email: email, response_type: 'complaint', extra_info: extra_info })
    end

    render json: {}
  end

  protected

  def aws_message
    @aws_message ||= AWS::SNS::Message.new request.raw_post
  end

  def log_incoming_message
    Rails.logger.info request.raw_post
  end

  def message
    @message ||= JSON.parse JSON.parse(request.raw_post)['Message']
  end

  def type
    message['notificationType']
  end
end
