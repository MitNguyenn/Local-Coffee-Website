RSpec.describe Ticket type: :model do
  describe "#validate" do
    it "is valid with valid attributes" do
      ticket = Ticket.new(TicketContent: "Issue with order", TicketResolved: false)
      expect(ticket).to be_valid
    end

    it "is invalid without TicketContent" do
      ticket = Ticket.new(TicketResolved: false)
      expect(ticket).not_to be_valid
      expect(ticket.errors[:TicketContent]).to include("cannot be blank")
    end
  end
end
