module TicketsHelper
  def ticket_select_items
    h_item = {}
    Ticket.number_owneds.keys.each do |key|
      puts key
      if Ticket.number_owned_to_amount(key) > 0
        h_item[Ticket.human_attribute_name("number_owned.#{key}")] = key
      end
    end
    h_item
  end
end
