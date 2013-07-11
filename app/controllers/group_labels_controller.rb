class GroupLabelsController < ApplicationController
  def create
    group_label_name = params[:group_label_name]
    if group_label_name.present?
      @group_label = GroupLabel.create(organization_id: current_organization.id, name: group_label_name)
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
