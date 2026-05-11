RSpec.describe 'Authentification process', type: :feature do
  before(:each) do
    spec_before
    DB[:Accounts].insert(email: 'test@bbc.com', hashedPassword: BCrypt::Password.create('password123'), first_name: 'Test')
  end

  describe 'Logging In' do
    it 'can reach the login page' do
        visit '/log-in'
        puts current_url
        puts page.status_code
        save_and_open_page
    end
    it 'allows the user to log in' do
      visit '/log-in'
      fill_in 'email', with: 'test@bbc.com'
      fill_in 'password', with: 'password123'
      click_button 'Log In'                        

      expect(current_path).to eq('/')
      expect(page).to have_content('Log out')
    end

    it 'shows an error for wrong credentials' do
      visit '/log-in'
      fill_in 'email', with: 'test@coffee.com'
      fill_in 'password', with: 'password124'
      click_button 'Log In'                         

      expect(page).to have_content('Log in')
      expect(current_path).to eq('/log-in')
    end
  end
end