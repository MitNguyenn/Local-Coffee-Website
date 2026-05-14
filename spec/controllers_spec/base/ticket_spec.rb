RSpec.describe "Help page and ticket submission", type: :feature do

  describe "GET /help" do
    it "renders the help page" do
      visit "/help"
      expect(current_path).to eq("/help")
    end

    it "displays all four problem type options" do
      visit "/help"
      expect(page).to have_select("problem_type", with_options: ["Query", "Technical", "Complaint", "Other"])
    end

    it "has an email field, description field and submit button" do
      visit "/help"
      expect(page).to have_field("form_useremail")
      expect(page).to have_field("form_request_description")
      expect(page).to have_button("Submit")
    end
  end

  describe "POST /help — validation" do
    it "shows an error when the email does not match any account" do
      visit "/help"
      fill_in "form_useremail", with: "nobody@nowhere.com"
      fill_in "form_request_description", with: "My order is missing"
      click_button "Submit"

      expect(current_path).to eq("/help")
      expect(page).to have_content("Missing info!")
    end

    it "shows an error when the description is blank" do
      visit "/help"
      fill_in "form_useremail", with: "testcust@bbc.com"
      fill_in "form_request_description", with: ""
      click_button "Submit"

      expect(current_path).to eq("/help")
      expect(page).to have_content("Missing info!")
    end

    it "shows an error when the description is only whitespace" do
      visit "/help"
      fill_in "form_useremail", with: "testcust@bbc.com"
      fill_in "form_request_description", with: "     "
      click_button "Submit"

      expect(current_path).to eq("/help")
      expect(page).to have_content("Missing info!")
    end

    it "does not create a ticket when validation fails" do
      before_count = DB[:Tickets].count

      visit "/help"
      fill_in "form_useremail", with: "nobody@nowhere.com"
      fill_in "form_request_description", with: "Should not save"
      click_button "Submit"

      expect(DB[:Tickets].count).to eq(before_count)
    end
  end

  describe "POST /help — successful submission by ticket type" do
    # Shared helper so each example stays concise
    def submit_ticket(type:, description: "This is a test request")
      visit "/help"
      fill_in "form_useremail",           with: "testcust@bbc.com"
      fill_in "form_request_description", with: description
      select type, from: "problem_type"
      click_button "Submit"
    end

    context "Query ticket" do
      it "redirects to home on success" do
        submit_ticket(type: "Query")
        expect(current_path).to eq("/")
      end

      it "persists a Query ticket for the correct user" do
        submit_ticket(type: "Query", description: "When does my order arrive?")
        ticket = DB[:Tickets].order(:ticket_id).last
        expect(ticket[:ticket_type]).to eq("query")
        expect(ticket[:ticket_content]).to eq("When does my order arrive?")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    context "Technical ticket" do
      it "redirects to home on success" do
        submit_ticket(type: "Technical")
        expect(current_path).to eq("/")
      end

      it "persists a Technical ticket for the correct user" do
        submit_ticket(type: "Technical", description: "The site won't load on Safari")
        ticket = DB[:Tickets].order(:ticket_id).last
        expect(ticket[:ticket_type]).to eq("technical")
        expect(ticket[:ticket_content]).to eq("The site won't load on Safari")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    context "Complaint ticket" do
      it "redirects to home on success" do
        submit_ticket(type: "Complaint")
        expect(current_path).to eq("/")
      end

      it "persists a Complaint ticket for the correct user" do
        submit_ticket(type: "Complaint", description: "My beans arrived crushed")
        ticket = DB[:Tickets].order(:ticket_id).last
        expect(ticket[:ticket_type]).to eq("complaint")
        expect(ticket[:ticket_content]).to eq("My beans arrived crushed")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    context "Other ticket" do
      it "redirects to home on success" do
        submit_ticket(type: "Other")
        expect(current_path).to eq("/")
      end

      it "persists an Other ticket for the correct user" do
        submit_ticket(type: "Other", description: "I have a general enquiry")
        ticket = DB[:Tickets].order(:ticket_id).last
        expect(ticket[:ticket_type]).to eq("other")
        expect(ticket[:ticket_content]).to eq("I have a general enquiry")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    it "creates exactly one ticket per submission" do
      before_count = DB[:Tickets].count
      submit_ticket(type: "Query")
      expect(DB[:Tickets].count).to eq(before_count + 1)
    end

    it "new ticket is unresolved by default" do
      submit_ticket(type: "Complaint")
      ticket = DB[:Tickets].order(:ticket_id).last
      expect(ticket[:ticket_resolved]).to be_falsy
    end
  end
end