# Ticket Spec file.

require 'spec_helper'

RSpec.describe "Help page and ticket submission", type: :feature do

  context "Given an anonymous visitor accessing the help centre" do
    context "When viewing the help page layout" do
      it "Then renders the correct help endpoint view" do
        visit "/help"
        expect(current_path).to eq("/help")
      end

      it "Then displays all four structured problem type select options" do
        visit "/help"
        expect(page).to have_select("problem_type", with_options: ["Query", "Technical", "Complaint", "Other"])
      end

      it "Then presents an email field, a description area, and a validation submit button" do
        visit "/help"
        expect(page).to have_field("form_useremail")
        expect(page).to have_field("form_request_description")
        expect(page).to have_button("Submit")
      end
    end
  end

  context "Given a user attempts to submit a ticket" do
    context "When providing invalid form payload fields" do
      it "Then rejects emails that do not match existing user accounts" do
        visit "/help"
        fill_in "form_useremail", with: "nobody@nowhere.com"
        fill_in "form_request_description", with: "My order is missing"
        click_button "Submit"

        expect(current_path).to eq("/help")
        expect(page).to have_content("Missing info!")
      end

      it "Then rejects forms where the text description area is left empty" do
        visit "/help"
        fill_in "form_useremail", with: "testcust"
        fill_in "form_request_description", with: ""
        click_button "Submit"

        expect(current_path).to eq("/help")
        expect(page).to have_content("Missing info!")
      end

      it "Then rejects descriptions consisting entirely of blank spacing strings" do
        visit "/help"
        fill_in "form_useremail", with: "testcust"
        fill_in "form_request_description", with: "     "
        click_button "Submit"

        expect(current_path).to eq("/help")
        expect(page).to have_content("Missing info!")
      end

      it "Then guarantees no underlying database row modifications are saved" do
        before_count = DB[:Tickets].count

        visit "/help"
        fill_in "form_useremail", with: "nobody@nowhere.com"
        fill_in "form_request_description", with: "Should not save"
        click_button "Submit"

        expect(DB[:Tickets].count).to eq(before_count)
      end
    end
  end

  context "Given a customer executes a successful ticket form validation" do
    def submit_ticket(type:, description: "This is a test request")
      visit "/help"
      fill_in "form_useremail",           with: "testcust"
      fill_in "form_request_description", with: description
      select type, from: "problem_type"
      click_button "Submit"
    end

    context "When selecting the Query category type" do
      it "Then redirects back onto the home root path context" do
        submit_ticket(type: "Query")
        expect(current_path).to eq("/")
      end

      it "Then writes a persistent query record linked over to the correct user account row" do
        submit_ticket(type: "Query", description: "When does my order arrive?")
        ticket = DB[:Tickets].order(:ticket_id).last
        
        expect(ticket[:ticket_type]).to eq("query")
        expect(ticket[:ticket_content]).to eq("When does my order arrive?")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    context "When selecting the Technical category type" do
      it "Then redirects back onto the home root path context" do
        submit_ticket(type: "Technical")
        expect(current_path).to eq("/")
      end

      it "Then writes a persistent technical record linked over to the correct user account row" do
        submit_ticket(type: "Technical", description: "The site won't load on Safari")
        ticket = DB[:Tickets].order(:ticket_id).last
        
        expect(ticket[:ticket_type]).to eq("technical")
        expect(ticket[:ticket_content]).to eq("The site won't load on Safari")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    context "When selecting the Complaint category type" do
      it "Then redirects back onto the home root path context" do
        submit_ticket(type: "Complaint")
        expect(current_path).to eq("/")
      end

      it "Then writes a persistent complaint record linked over to the correct user account row" do
        submit_ticket(type: "Complaint", description: "My beans arrived crushed")
        ticket = DB[:Tickets].order(:ticket_id).last
        
        expect(ticket[:ticket_type]).to eq("complaint")
        expect(ticket[:ticket_content]).to eq("My beans arrived crushed")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    context "When selecting the Other category type" do
      it "Then redirects back onto the home root path context" do
        submit_ticket(type: "Other")
        expect(current_path).to eq("/")
      end

      it "Then writes a persistent other record linked over to the correct user account row" do
        submit_ticket(type: "Other", description: "I have a general enquiry")
        ticket = DB[:Tickets].order(:ticket_id).last
        
        expect(ticket[:ticket_type]).to eq("other")
        expect(ticket[:ticket_content]).to eq("I have a general enquiry")
        expect(ticket[:user_id]).to eq(1)
      end
    end

    context "When evaluating overall data persistence metrics" do
      it "Then increments the master transaction dataset count by exactly one record entry" do
        before_count = DB[:Tickets].count
        submit_ticket(type: "Query")
        
        expect(DB[:Tickets].count).to eq(before_count + 1)
      end

      it "Then ensures new support items default directly to an unresolved status flag state" do
        submit_ticket(type: "Complaint")
        ticket = DB[:Tickets].order(:ticket_id).last
        
        expect(ticket[:ticket_resolved]).to be_falsy
      end
    end
  end
end