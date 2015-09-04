class SignaturesController < ApplicationController
  before_filter :ensure_current_org
  skip_before_filter :check_signature
  skip_before_filter :check_all_signatures

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
    if !current_person.code_of_conduct_signed?(current_organization)
      redirect_to code_of_conduct_signatures_path
    elsif !current_person.statement_of_faith_signed?(current_organization)
      redirect_to statement_of_faith_signatures_path
    else
      if current_person.accpeted_all_signatures?(current_organization)
        redirect_to root_path, notice: I18n.t("signatures.signed_a_signature")
      else
        redirect_to root_path, notice: I18n.t("signatures.declined_a_signature")
      end
    end
  end
end
