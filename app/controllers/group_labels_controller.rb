class GroupLabelsController < ApplicationController
  def create
    label_name = params[:name]
    if label_name.present?
      @group_label = current_organization.group_labels.create(name: label_name)
      @message = t('groups.label_name_is_added')
    else
      @message = t('groups.label_name_is_required')
    end
  end

  def destroy
    authorize! :manage, current_organization
    @group_label = current_organization.group_labels.find(params[:id])
    @group_label.destroy
    render nothing: true
  end
end
