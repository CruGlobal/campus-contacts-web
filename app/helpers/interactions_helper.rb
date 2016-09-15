module InteractionsHelper
  def much_wiser_date(timestamp, options = {})
    corrected = timestamp.utc + current_user.timezone.to_i.hours
    content_tag(:span,
                "#{time_ago_in_words(timestamp)} ago",
                class: options[:custom_class],
                title: corrected.strftime('%B %d, %Y %l:%M%P'))
  end
end
