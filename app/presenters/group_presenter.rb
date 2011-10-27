class GroupPresenter < DelegatePresenter::Base
  def labels
    s(self.group_labels.collect(&:to_s).join(', '))
  end
  
  def leaders_names
    leaders.collect(&:name).join(', ')
  end
end