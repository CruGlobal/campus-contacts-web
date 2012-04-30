module ApplicationHelper
  include ActionView::Helpers::DateHelper  

  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  end

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
      url_params = ([parts[1]] + hash.map {|k,v| "#{k}=#{v}"}).compact.join('&')
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
  
  def declare_ownership(name)
    name.slice(-1, 1) == 's' ? "#{name}'" : "#{name}'s"
  end
  
  def pretty_tag(txt)
    txt.to_s.gsub(/\s/, "_").gsub(/(?!-)\W/, "").downcase
  end

  def flatten_hash(hash = params, ancestor_names = [])
    flat_hash = {}
    hash.each do |k, v|
      names = Array.new(ancestor_names)
      names << k
      if v.is_a?(Hash)
        flat_hash.merge!(flatten_hash(v, names))
      else
        key = flat_hash_key(names)
        key += "[]" if v.is_a?(Array)
        flat_hash[key] = v
      end
    end
    
    flat_hash
  end

  def flat_hash_key(names)
    names = Array.new(names)
    name = names.shift.to_s.dup 
    names.each do |n|
      name << "[#{n}]"
    end
    name
  end
  
  def questionnaire_engine_stylesheets(options = {})
    output = []
    output << "qe/qe.screen"
    return output
  end

  def questionnaire_engine_javascripts(options = {})
    output = []
    output << "qe/jquery.validate.pack"
    output << "qe/jquery.metadata"
    output << "qe/jquery.tooltips.min"
    output << "qe/qe.common"
    if options[:area] == :public
      output << "qe/qe.public"
    else
      output << "qe/qe.admin"
      output << "qe/ckeditor/ckeditor"
    end
    output << "qe/jquery.scrollTo-min"
    output << {:cache => true} if options[:cache]
    return output 
  end

  def questionnaire_engine_includes(options = {})
    return "" if @qe_already_included
    @qe_already_included=true
    
    js = questionnaire_engine_javascripts(options).collect {|file| javascript_include_tag(file)}.join("\n")
    css = questionnaire_engine_stylesheets(options).collect {|file| stylesheet_link_tag(file)}.join("\n")
    "#{js}\n#{css}\n".html_safe
  end
  
  def calendar_date_select_tag(name, value = nil, options = {})
    options.merge!({'data-calendar' => true})
    text_field_tag(name, value, options )
  end
  
  def tip(t)
    image_tag('qe/icons/question-balloon.png', :title => t, :class => 'tip')
  end

  def spinner(extra = nil)
    e = extra ? "spinner_#{extra}" : 'spinner'
    image_tag('spinner.gif', :id => e, :style => 'display:none', :class => 'spinner')
  end
end
