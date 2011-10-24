module ApplicationHelper
  def tip(tip)
    "<span class=\"tiplight\" title=\"#{tip}\" style=\"float: none;\"></span>".html_safe
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
  
  def times(start_time, end_time)
    midnight = Time.now.beginning_of_day
    # start_time = midnight + start_time.hours
    # end_time = midnight.beginning_of_day + end_time.hours
    time_options = []
    start_time.to_i.step(end_time.to_i, 900) do |time|
      time_options << [(midnight + time).to_s(:time), time]
    end
    time_options
  end  
end
