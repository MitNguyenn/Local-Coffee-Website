RSpec.describe Ticket do
  describe "#validate" do
    it "is valid with valid attributes" do
      ticket = Ticket.new(ticketContent: "Issue with order", ticketResolved: false)
      expect(ticket).to be_valid
    end

    it "is invalid without ticketContent" do
      ticket = Ticket.new(ticketResolved: false)
      expect(ticket).not_to be_valid
      expect(ticket.errors[:ticketContent]).to include("cannot be blank")
    end
  end

  describe "#resolved?" do
    it "returns true if the ticket is resolved" do
      ticket = Ticket.new(ticketResolved: true)
      expect(ticket.resolved?).to be true
    end
  end
end
