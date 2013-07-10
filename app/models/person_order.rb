class PersonOrder
  attr_accessor :people, :order

  def initialize(order, organization = nil)
    @order = {}
    @organization = organization

    order.split(',').each do |x|
      parts = x.to_s.strip.split(' ')
      parts.collect { |p| p.blank? ? nil : p.to_s.strip.downcase }
      parts = parts.compact;
      @order[parts.first.to_sym] = %w(asc desc).include?(parts.second) ? parts.second : 'asc' if parts.first
    end
  end

  def order(people)
    ordered_people = people

    @order.each do |key, direction|
      case key

        when :first_name
          ordered_people = ordered_people.order("people.first_name #{direction}")

        when :last_name
          ordered_people = ordered_people.order("people.last_name #{direction}")

        when :gender
          ordered_people = ordered_people.order("people.gender #{direction}")

        when :followup_status
          ordered_people = ordered_people.order_by_followup_status("followup_status #{direction}")

        when :permission
          ordered_people = ordered_people.order_by_permission("permission_id #{direction}")

        when :primary_phone
          ordered_people = ordered_people.order_by_primary_phone_number("number #{direction}")

        when :primary_email
          ordered_people = ordered_people.order_by_primary_email_address("email #{direction}")

        else
          ordered_people = ordered_people.order("#{key} #{direction}")

      end
    end

    ordered_people
  end
end
