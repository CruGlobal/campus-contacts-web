ActiveAdmin.register Survey do
  config.clear_action_items!

  filter :id
  filter :title

  controller do
    def index
      params[:order] = "id_asc"
      super
    end
  end

  index do
    column :id
    column :title
    column :organization
    column :terminology
    column "Link" do |survey|
      short_url = short_survey_url(survey.id, host: APP_CONFIG['public_host'], port: (APP_CONFIG['public_port'] == 80 ? nil : APP_CONFIG['public_port']), protocol: 'http')
      link_to(short_url, short_url, target: '_blank')
    end
    column "Actions" do |survey|
      ret = []
      ret << link_to("Questions", admin_survey_questions_path(survey))
      raw ret.join(' ')
    end
  end

  member_action :questions do
    if @survey = Survey.find_by_id(params[:id])
      @page_title = "All Questions for '#{@survey.title}'"
      @questions = Array.new
      locked_questions = Element.where(attribute_name: ["first_name", "last_name", "phone_number"])
      @questions = (locked_questions + @survey.questions).uniq
    else
      redirect_to admin_surveys_path, :notice => "Invalid survey. Please try again later."
    end
  end
end

ActiveAdmin.register Question do
 belongs_to :survey
end