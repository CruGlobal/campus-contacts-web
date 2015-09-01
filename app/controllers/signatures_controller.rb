class SignaturesController < ApplicationController
  before_filter :ensure_current_org
  skip_before_filter :check_signature

  def code_of_conduct
  end

  def statement_of_faith
  end

  def action_for_signature
    kind = params[:kind]
    status = params[:status]
    if kind.blank? || status.blank?
      redirect_to root_path, alert: I18n.t("signatures.invalid_parameters")
    else
      current_person.sign_a_signature(current_organization, kind, status)
      go_to_process
    end
  end

  private
  def go_to_process
    if !current_person.signed_signature?(current_organization, Signature::SIGNATURE_CODE_OF_CONDUCT)
      redirect_to code_of_conduct_signatures_path
    elsif !current_person.signed_signature?(current_organization, Signature::SIGNATURE_STATEMENT_OF_FAITH)
      redirect_to statement_of_faith_signatures_path
    else
      redirect_to root_path, notice: I18n.t("signatures.signed_a_signature")
    end
  end
end
