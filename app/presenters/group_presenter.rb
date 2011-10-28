class GroupPresenter < DelegatePresenter::Base
  def labels
    s(helpers.content_tag(:ul, s(self.group_labels.collect {|l| helpers.content_tag(:li, helpers.content_tag(:span, h(l), class: 'name') + s('<a href="#" class="delete">x</a>'), data: {id: l.id})}.join)))
  end
  
  def leaders_names
    leaders.collect(&:name).join(', ')
  end
end