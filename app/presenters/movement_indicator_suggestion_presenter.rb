class MovementIndicatorSuggestionPresenter < DelegatePresenter::Base

  def suggestion
    label_html = "<span class=\"tip\" title=\"#{I18n.t('labels.' + label.i18n + '_definition')}\">#{I18n.t("labels.#{label.i18n}")}</span>"
    if action == 'add'
      I18n.t("movement_indicator_suggestions.reasons.#{reason}", name: helpers.link_to(person, "/profile/#{person.to_param}"), label: label_html, label_sentence: I18n.t("labels.#{label.i18n}_sentence"))
    #else
      #I18n.t("movement_indicator_suggestions.remove_suggestion_html", name: helpers.link_to(person, "/profile/#{person.to_param}"), label: label_html, label_sentence: I18n.t("labels.#{label.i18n}_sentence"))
    end
  end
end
