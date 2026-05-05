it "allows a user to create a new account with a valid 12-character password" do
  visit "/register"

  fill_in "FirstName", with: "Test"
  fill_in "LastName", with: "User"
  fill_in "email", with: "testemail@gmail.com"
  fill_in "password1", with: "password12345" 
  fill_in "password2", with: "password12345"
  fill_in "PhoneNumber", with: "07123456789"
  fill_in "Address", with: "123 Test Street"
  fill_in "postcode", with: "TE5 7ST"

  click_button "Register"
  
  expect(page).to have_current_path("/")
end
