class Apis::V4::OrganizationalLabelsController < Apis::V3::BaseController

  def index
    order = params[:order] || 'id'

    list = add_includes_and_order(organizational_labels, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end
  private

  def organizational_labels
    current_person.organizational_labels
  end

  def get_organizational_label
    @organizational_label = add_includes_and_order(organizational_labels)
                .find(params[:id])

  end

end
