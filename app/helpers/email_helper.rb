module EmailHelper
  def email_image_tag(image, **options)
    attachments[image] = File.read(Rails.root.join("app/assets/images/#{image}"))
    image_tag attachments[image].url, **options
  end

  def fancy_email_button(body, url, html_options = {})
    default_style = 'background-color: #3EB1C8; color: white; padding: 1em 0; text-decoration: none; '\
                      'width: 200px; display: inline-block; text-align: center;'
    html_options[:style] = default_style + (html_options[:style] || '')
    link_to(body, url, html_options)
  end
end
