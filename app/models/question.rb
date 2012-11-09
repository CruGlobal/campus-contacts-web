# Question
# - An individual question element
# - children: TextField, ChoiceField, DateField, FileField

# :kind         - 'TextField', 'ChoiceField', 'DateField' for single table inheritance (STI)
# :label        - label for the question, such as "First name"
# :style        - essay|phone|email|numeric|currency|simple, selectbox|radio, checkbox, my|mdy
# :required     - is this question itself required or optional?
# :content      - choices (one per line) for choice field

class Question < Element
  include ActionController::RecordIdentifier # dom_id
  has_many :sheet_answers, :class_name => "Answer", :foreign_key => "question_id", :dependent => :destroy

  belongs_to :related_question_sheet, :class_name => "QuestionSheet", :foreign_key => "related_question_sheet_id"

  # validates_inclusion_of :required, :in => [false, true]

  # a question has one response per AnswerSheet (that is, an instance of a user filling out the question)
  # generally the response is a single answer
  # however, "Choose Many" (checkbox) questions have multiple answers in a single response

  attr_accessor :answers

  # @answers = nil            # one or more answers in response to this question
  # @mark_for_destroy = nil   # when something is unchecked, there are less answers to the question than before


  # a question is disabled if there is a condition, and that condition evaluates to false
  # could set multiple conditions to influence this question, in which case all must be met
  # def active?
  #   # find first condition that doesn't pass (nil if all pass)
  #   self.conditions.find(:all).find { |c| !c.evaluate? }.nil?  # true if all pass
  # end

  # def conditions_attributes=(new_conditions)
  #   conditions.collect(&:destroy)
  #   conditions.reload
  #   (0..(new_conditions.length - 1)).each do |i|
  #     i = i.to_s
  #     expression = new_conditions[i]["expression"]
  #     trigger_id = new_conditions[i]["trigger_id"].to_i
  #     unless expression.blank? || !page.questions.collect(&:id).include?(trigger_id) || conditions.collect(&:trigger_id).include?(trigger_id)
  #       conditions.create(:question_sheet_id => question_sheet_id, :trigger_id => trigger_id,
  #                         :expression => expression, :toggle_page_id => page_id,
  #                         :toggle_id => self.id)
  #     end
  #   end
  # end

  # element view provides the element label with required indicator
  def default_label?
    true
  end

  # css class names for javascript-based validation
  def validation_class(answer_sheet)
    if self.required?(answer_sheet)
      ' required '
    else
      ''
    end
  end

  # just in case something slips through client-side validation?
  # def valid_response?
  #   if self.required? && !self.has_response? then
  #     false
  #   else
  #     # other validations
  #     true
  #   end
  # end

  # just in case something slips through client-side validation?
  # def valid_response_for_answer_sheet?(answers)
  #    return true if !self.required?
  #    answer  = answers.detect {|a| a.question_id == self.id}
  #    return answer && answer.value.present?
  #    # raise answer.inspect
  #  end

  # shortcut to return first answer
  def response(app)
    responses(app).first.to_s
  end

  def display_response(app)
    r = responses(app)
    if r.blank?
      ""
    else
      r.join(", ")
    end
  end

  def responses(app)
    return [] unless app
    # try to find answer from external object
    if !object_name.blank? and !attribute_name.blank?
      obj = object_name == 'application' ? app : eval("app." + object_name)
      if obj.nil? or eval("obj." + attribute_name + ".nil?")
        []
      else
        [eval("obj." + attribute_name)]
      end
    else
      app.answers_by_question[id] || []
      # Answer.where(:answer_sheet_id => app.id, :question_id => self.id)
    end
  end

  # set answers from posted response
  def set_response(values, app)
    values = Array.wrap(values)
    if object_name.present? && attribute_name.present?
      object = object_name == 'application' ? app : eval("app." + object_name)
      unless object.present?
        if object_name.include?('.')
          objects = object_name.split('.')
          object = eval("app." + objects[0..-2].join('.') + ".create_" + objects.last)
          eval("app." + objects[0..-2].join('.')).reload
        end
      end
      unless responses(app) == values
        value = values.first
        if self.is_a?(DateField) && value.present?
          begin
            value = Date.strptime(value, (I18n.t 'date.formats.default'))
          rescue
            return value
          end
        end
        object.send("#{attribute_name}=".to_sym, value) if object
      end
    else
      @answers ||= []
      if multiple_answers_allowed?
        @mark_for_destroy ||= []
        # go through existing answers (in reverse order, as we delete)
        (@answers.length - 1).downto(0) do |index|
          # reject: skip over responses that are unchanged
          unless values.reject! {|value| value == @answers[index].value}
            # remove any answers that don't match the posted values
            @mark_for_destroy << @answers[index]   # destroy from database later
            @answers.delete_at(index)
          end
        end

        # insert any new answers
        for value in values
          if @mark_for_destroy.empty?
            answer = Answer.new(:question_id => self.id, :answer_sheet_id => app.id)
          else
            # re-use marked answers (an update vs. a delete+insert)
            answer = @mark_for_destroy.pop
          end
          answer.set(value)
          @answers << answer
        end
      else
        answer = Answer.find_by_question_id_and_answer_sheet_id(id, app.id) || Answer.new(:question_id => self.id, :answer_sheet_id => app.id)
        answer.set(values.first)
        @answers << answer
      end
    end
  end

  def save_file(answer_sheet, file)
    @answers.collect(&:destroy) if @answers
    answer = Answer.create!(:question_id => self.id, :answer_sheet_id => answer_sheet.id, :attachment => file)
  end

  # save this question's @answers to database
  def save_response(answer_sheet, question = nil)
    unless @answers.nil?
      for answer in @answers
        if answer.is_a?(Answer)
          answer.answer_sheet_id = answer_sheet.id
          answer.save!

          if question.present? && question.trigger_words.present?
            question.trigger_words.split(",").each do |t|
              if answer.value.include? t
                send_notifications(question, answer_sheet.person, answer.value)
              end
            end
          end

        end
      end
    end

    # remove others
    unless @mark_for_destroy.nil?
      for answer in @mark_for_destroy
        answer.destroy
      end
      @mark_for_destroy.clear
    end
  rescue TypeError
    raise answer.inspect
  end

  def send_notifications(question, person, answer)
    msg = generate_notification_msg(person, answer, shorten_link(person.id))

    if question.notify_via == "Email"
      send_email_to_leaders(question.leaders, msg)
    elsif question.notify_via == "SMS"
      send_sms_to_leaders(question.leaders, msg)
    else #send to SMS AND Email
      send_sms_to_leaders(question.leaders, msg)
      send_email_to_leaders(question.leaders, msg)
    end
  end

  def send_sms_to_leaders(leaders, msg)
    leaders.each do |l|
      SentSms.create!(message: msg, recipient: l.phone_number)
    end
  end

  def send_email_to_leaders(leaders, msg)
    SurveyMailer.enqueue.notify(leaders.reject{|leader| leader unless leader.has_a_valid_email?}.collect(&:email).compact, msg)
  end

  def shorten_link(id)
    short_profile_link = BITLY_CLIENT.shorten(Rails.application.routes.url_helpers.person_url(id,
    :host => APP_CONFIG['bitly_host'] || 'www.missionhub.com', :port => APP_CONFIG['bitly_port'] || 80, :only_path => false)).short_url
  end

  def generate_notification_msg(person, answer, link)
   "#{person.name} (#{person.phone_number}, #{person.email}) just replied to a survey with #{answer}. Profile link: #{link}"
  end

  # has any sort of non-empty response?
  def has_response?(answer_sheet = nil)
    if answer_sheet.present?
      answers = responses(answer_sheet)
    else
      answers = Answer.where(:question_id => self.id)
    end
    return false if answers.length == 0
    answers.each do |answer|   # loop through Answers
      value = answer.is_a?(Answer) ? answer.value : answer
      return true if (value.is_a?(FalseClass) && value === false) || value.present?
    end
    return false
  end

  def required?(answer_sheet = nil)
    super() || (!answer_sheet.nil? && !choice_field.nil? && choice_field.has_answer?('1', answer_sheet))
  end

  def multiple_answers_allowed?
    false
  end

  def email_should_be_unique_msg
    I18n.t('sms.email_should_be_unique_msg')
  end

  def email_invalid
    I18n.t('sms.email_invalid_msg')
  end

  private
    def all_leaders_have_valid_email?
      leaders.each do |leader|
        errors.add(:leaders,"mello")
        return false unless leader.has_a_valid_email?
      end
    end

end
