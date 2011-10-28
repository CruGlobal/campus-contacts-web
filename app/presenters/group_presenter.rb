class GroupPresenter < DelegatePresenter::Base
  def labels
    s(helpers.content_tag(:ul, s(self.group_labels.collect {|l| helpers.content_tag(:li, helpers.content_tag(:span, h(l), class: 'name') + s('<a href="#" class="delete">x</a>'), data: {id: l.id})}.join)))
  end
  
  def leaders_names
    leaders.collect(&:name).join(', ')
  end
  
  def meets_at
    case meets
    when 'sporadically' then I18n.t('groups.show.sporadically')
    when 'weekly'
      I18n.t('groups.show.weekly', day: I18n.t('date.day_names')[meeting_day], start_time: human_start_time, end_time: human_end_time)
    when 'monthly'
      I18n.t('groups.show.monthly', day: meeting_day.ordinalize, start_time: human_start_time, end_time: human_end_time)
    else
      ''
    end
  end
  
  def human_start_time
    I18n.l(Time.now.beginning_of_day + start_time, format: :time_only)
  end
  
  def human_end_time
    I18n.l(Time.now.beginning_of_day + end_time, format: :time_only)
  end
end