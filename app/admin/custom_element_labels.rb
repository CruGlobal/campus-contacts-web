ActiveAdmin.register CustomElementLabel do
#  config.clear_action_items!
  menu false
  filter :label

  controller do
    def index
      super
    end

    def update
      if @custom_element_label = CustomElementLabel.find_by_id(params[:id])
        @custom_element_label.update_attributes(params[:custom_element_label])
        redirect_to admin_survey_questions_path(@custom_element_label.survey_id), :notice => "You have successfully updated a custom label."
      else
        redirect_to admin_surveys_path, :notice => "Invalid custom label, please try again later."
      end
    end

    def create
      survey_id = params[:custom_element_label][:survey_id]
      question_id = params[:custom_element_label][:question_id]
      if survey_id.present? && question_id.present?
        label = params[:custom_element_label][:label]
        if label.present?
          @custom_element_label = CustomElementLabel.find_or_create_by_survey_id_and_question_id(survey_id, question_id)
          @custom_element_label.label = label
          @custom_element_label.save
          redirect_to admin_survey_questions_path(survey_id), :notice => "You have successfully created a custom label."
        else
          redirect_to :back, :notice => "Label cannot be blank"
        end
      else
        redirect_to admin_surveys_path, :notice => "Invalid values of fields, please try again later."
      end
    end

    def destroy
      if @custom_element_label = CustomElementLabel.find_by_id(params[:id])
        survey_id = @custom_element_label.survey_id
        @custom_element_label.destroy
        redirect_to admin_survey_questions_path(survey_id), :notice => "You have successfully deleted a custom label."
      else
        redirect_to admin_surveys_path, :notice => "Invalid custom label, please try again later."
      end
    end
  end

  form :partial => "form"

  index do
    column :label
    column :survey_id
    column :question_id
  end

#  form :partial => 'form'

end