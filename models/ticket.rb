# In ./models/ticket.rb
class Ticket < Sequel::Model(:Tickets)
  set_primary_key :ticketID

  def validate
    super
    # Use self. to distinguish the column method from a Constant
    errors.add(:TicketContent, "cannot be blank") if !self.TicketContent || self.TicketContent.strip.empty?
  end

  def resolved?
    self.TicketResolved == true
  end
end
