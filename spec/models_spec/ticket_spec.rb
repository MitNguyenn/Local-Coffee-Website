RSpec.describe Ticket do
  describe "#validate" do
    it "is valid with valid attributes" do
      # Use Capitalized keys to match your DB schema
      ticket = Ticket.new(TicketContent: "Issue with order", TicketResolved: false)
      expect(ticket).to be_valid
    end

    it "is invalid without TicketContent" do
      ticket = Ticket.new(TicketResolved: false)
      expect(ticket).not_to be_valid
      expect(ticket.errors[:TicketContent]).to include("is not present") 
    end
  end

  describe "#resolved?" do
    it "returns true if the ticket is resolved" do
      ticket = Ticket.new(TicketResolved: true)
      # Ensure your Ticket model has a 'resolved?' method defined
      expect(ticket.resolved?).to be true
    end
  end
end
