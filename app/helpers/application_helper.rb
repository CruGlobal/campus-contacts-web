module ApplicationHelper
  def tip(tip)
    "<div>#{tip}</div>".html_safe
  end
  
  def print_tree(tree)
    return '' unless tree.present?
    ret = '<ul>'
    tree.sort.each do |sub|
      ret += "<li>#{link_to(sub.name, person_organization_memberships_path(current_person, organization_id: sub.id), method: :post)} #{print_tree(sub.children)}</li>"
    end
    (ret + '</ul>').html_safe
  end
  
  def spinner(extra = nil)
    e = extra ? "spinner_#{extra}" : 'spinner'
    image_tag('spinner.gif', id: e, style: 'display:none', class: 'spinner')
  end
  
  def add_params(url, hash)
    if url.is_a?(Hash)
      url.merge(hash)
    else
      parts = url.split('?')
      url_params = (parts[1] + hash.map {|k,v| "#{k}=#{v}"}).join('&')
      [parts[0], url_params].join('?')
    end
  end
  
  def site_name
    mhub? ? '' : 'MissionHub'
  end
  
  def site_email
    mhub? ? 'support@mhub.cc' : 'support@missionhub.com'
  end
  
end
