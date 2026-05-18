RSpec.describe Ticket, type: :model do
  describe "#validate" do
    it "is valid with valid attributes" do
      ticket = Ticket.new(ticket_content: "Issue with order", ticket_resolved: false)
      expect(ticket).to be_valid
    end

    it "is invalid without ticket_content" do
      ticket = Ticket.new(ticket_resolved: false)
      expect(ticket).not_to be_valid
      expect(ticket.errors[:ticket_content]).to include("cannot be blank")
    end
  end
end
