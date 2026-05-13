# In ./models/ticket.rb
class Ticket < Sequel::Model(:Tickets)
  set_primary_key :ticket_id

  def validate
    super
    # Use self. to distinguish the column method from a Constant
    errors.add(:ticket_content, "cannot be blank") if !self.ticket_content || self.ticket_content.strip.empty?
  end

  def resolved?
    self.ticket_resolved == true
  end
end
