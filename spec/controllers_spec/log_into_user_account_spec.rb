it "logs into a user account with valid credentials" do
  # First, create a test account
  DB[:Accounts].insert(
    UserID: 12345678,
    FirstName: "Test",
    LastName: "User",
    email: "test.user@example.com",
    password: BCrypt::Password.create("password123")
  )

  # Then, attempt to log in
  visit '/login'
  fill_in 'Email', with: "test.user@example.com"
  fill_in 'Password', with: "password123"
  click_button 'Login'

  # Verify the login was successful
  expect(page).to have_url('/')
end