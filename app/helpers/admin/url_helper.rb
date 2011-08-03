module UrlHelper
  def sort_link(builder, attribute, *args)
    old_sort = builder.sorts.first
    search_attributes = params[:q] || {}
    attr_name = attribute.to_s
    name = (args.size > 0 && !args.first.is_a?(Hash)) ? args.shift.to_s : attr_name.humanize
    if old_sort
      prev_attr, prev_order = old_sort.name, old_sort.dir
    else
      prev_attr, prev_order = nil, nil
    end
    current_order = prev_attr == attr_name ? prev_order : nil
    new_order = current_order == 'asc' ? 'desc' : 'asc'
    options = args.first.is_a?(Hash) ? args.shift : {}
    html_options = args.first.is_a?(Hash) ? args.shift : {}
    css = ['sort_link', current_order].compact.join(' ')
    html_options[:class] = [css, html_options[:class]].compact.join(' ')
    id = rand(999999999999)
    options.merge!(
      'q' => search_attributes.merge(
        's' => {id => {dir: new_order, name: attr_name}}
      )
    )
    link_to [ERB::Util.h(name), order_indicator_for(current_order)].compact.join(' ').html_safe,
            url_for(options),
            html_options
  end
  
  private
  
  def order_indicator_for(order)
    if order == 'asc'
      '&#9650;'
    elsif order == 'desc'
      '&#9660;'
    else
      nil
    end
  end
end