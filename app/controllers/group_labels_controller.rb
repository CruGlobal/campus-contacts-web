class GroupLabelsController < ApplicationController
  def create
    authorize! :manage, current_organization
    @group_label = current_organization.group_labels.create(params[:group_label])
  end
  
  def destroy
    authorize! :manage, current_organization
    @group_label = current_organization.group_labels.find(params[:id])
    @group_label.destroy
    render nothing: true
  end
end
