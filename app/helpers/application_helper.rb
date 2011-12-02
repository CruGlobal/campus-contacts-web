module ApplicationHelper
  def tip(tip)
    "<span class=\"tiplight\" title=\"#{h(tip)}\" style=\"float: none;\"></span>".html_safe
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
  
  def link_to_remove_fields(f, hidden)
    f.hidden_field(:_destroy) + link_to(' ', '#', class: 'remove_field', style: hidden ? 'display:none' : '')
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("people/#{association.to_s.singularize}_fields", :builder => builder, no_remove: false)
    end
    link_to_function(name, raw("addFields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end
  
  def times(start_time, end_time)
    midnight = Time.now.beginning_of_day
    # start_time = midnight + start_time.hours
    # end_time = midnight.beginning_of_day + end_time.hours
    time_options = []
    start_time.to_i.step(end_time.to_i, 900) do |time|
      # raise (midnight + time).to_formatted_s("%l:%M %p").inspect
      time_options << [l(midnight + time, format: :time_only), time]
    end
    time_options
  end  
  
  def no_left_sidebar
    case "#{params[:controller]}/#{params[:action]}"
    when 'groups/new', 'groups/edit', 'groups/create', 'groups/update', 'organizations/index', 'organizations/edit', 'organizations/update',
         'organizations/new'
      true
    else
      false
    end
  end
end
