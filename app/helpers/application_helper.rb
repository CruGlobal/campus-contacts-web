module ApplicationHelper
  def tip(tip)
    "<div>#{tip}</div>".html_safe
  end
  
  def print_tree(tree)
    return '' unless tree.present?
    ret = '<ul>'
    tree.sort.each do |sub|
      ret += "<li>#{link_to(sub.name, person_organization_memberships_path(current_person, :organization_id => sub.id), :method => :post)} #{print_tree(sub.children)}</li>"
    end
    (ret + '</ul>').html_safe
  end
end
