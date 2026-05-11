class Ticket < Sequel::Model(:Tickets)
  set_primary_key :ticketID

  def validate
    super
    # Use the capitalized name from your schema
    errors.add(:TicketContent, "cannot be blank") if !TicketContent || TicketContent.strip.empty?
  end

  def resolved?
    # Use the capitalized name from your schema
    self.TicketResolved == true
  end
end
