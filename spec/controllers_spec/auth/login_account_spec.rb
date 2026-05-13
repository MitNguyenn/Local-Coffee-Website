RSpec.describe 'Authentification process', type: :feature do

  describe 'Logging In' do
    it 'allows the user to log in' do
      
      log_in_as('test@bbc.com', 'password123')

      expect(current_path).to eq('/')
      expect(page).to have_content('Log out')
    end

    it 'shows an error for wrong credentials' do
      log_in_as('test@coffee.com', 'password124')                       

      expect(page).to have_content('Log in')
      expect(current_path).to eq('/log-in')
    end

    it 'blocks suspended user from logging in and shows message' do

      log_in_as('suspended@bbc.com', 'suspended123')

      expect(page).to have_content('Your account has been suspended. Please contact support.')
      expect(current_path).to eq('/log-in')
    end
  end

  it 'allows the user to log out' do
    visit '/log-out'
    expect(page).to have_content('Log in')
  end
end