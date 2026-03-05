class Ticket < Sequel::Model(:Tickets)
  set_primary_key :ticketID

  def validate
    super
    errors.add(:ticketContent, "cannot be blank") if !ticketContent || ticketContent.empty?
  end

  # Logic to handle the boolean field from your PDF
  def resolved?
    self.ticketResolved == true
  end
end
