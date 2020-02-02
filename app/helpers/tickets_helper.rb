module TicketsHelper
  def ticket_select_items
    h_item = {}
    Ticket.number_owneds.keys.each do |key|
      h_item[Ticket.human_attribute_name("number_owned.#{key}")] = key
    end
    h_item
  end
end
