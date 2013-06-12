class MovementIndicatorSuggestionPresenter < DelegatePresenter::Base

  def suggestion
    if action == 'add'
      I18n.t("movement_indicator_suggestions.suggestion_html", name: helpers.link_to(person, "/profile/#{person.to_param}"), label: I18n.t("labels.#{label.i18n}_sentence"), label_sentence: I18n.t("labels.#{label.i18n}_sentence"))
    else
      I18n.t("movement_indicator_suggestions.remove_suggestion_html", name: helpers.link_to(person, "/profile/#{person.to_param}"), label: I18n.t("labels.#{label.i18n}"), label_sentence: I18n.t("labels.#{label.i18n}_sentence"))
    end
  end
end
