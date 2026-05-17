RSpec.describe 'Home page', type: :feature do

  it 'opens the log in page' do
    visit '/log-in'
    expect(current_path).to eq('/log-in')
    expect(page).to have_content('Welcome Back')
  end

  it 'opens the beans menu' do
    visit '/'
    find('.pill-half.left').click
    expect(current_path).to eq('/coffee-beans')
    expect(page).to have_content('Our Coffee Beans')
  end

  it 'opens the drinks menu' do
    visit '/'
    find('.pill-half.right').click
    expect(current_path).to eq('/drinks')
    expect(page).to have_content('Our Hot Drinks')
  end

  it 'opens the help page' do
    visit '/'
    click_link 'Help'
    expect(current_path).to eq('/help')
    expect(page).to have_content('Request description')
  end

  it 'opens the discount page' do
    visit '/'
    click_link 'Discounts'
    expect(current_path).to eq('/discounts')
    expect(page).to have_content('Our Current Discounts!')
  end

  context 'when logged in as user' do 
    before(:each) { log_in_as('testcust@bbc.com', 'testcust@bbc.com')}
    it 'opens the loyalty card page' do
      visit '/'
      click_link 'Loyalty Card'
      expect(current_path).to eq('/loyalty-card')
      expect(page).to have_content('Scan this QR code in store!')
    end

    it 'opens the my orders page' do
      visit '/'
      click_link 'My Orders'
      expect(current_path).to eq('/my-orders')
      expect(page).to have_content('Live Orders')
    end

    it 'opens the account settings page' do
      visit '/'
      click_link 'Account settings'
      expect(current_path).to eq('/account-settings')
      expect(page).to have_content('Personal Details')
    end
  end

  describe 'Staff portal access' do
    context 'when not logged in' do
      it 'sends the user to the homepage' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/log-in')
      end
    end
    
    context 'when logged in as a customer' do
      before (:each) {log_in_as('testcust@bbc.com', 'testcust@bbc.com')}
      
      it 'sends customer back to homepage' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/')
      end
    end

    context 'when logged in as an admin' do
      before(:each) { log_in_as('testadmin@bbc.com', 'testadmin@bbc.com') }

      it 'shows the staff portal for admins' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Staff Portal')
      end
    end

    context 'when logged in as a barista' do
      before(:each) { log_in_as('testbarista@bbc.com', 'testbarista@bbc.com') }

      it 'shows the staff portal for baristas' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Staff Portal')
      end
    end

    context 'when logged in as a manager' do
      before(:each) { log_in_as('testmanager@bbc.com', 'testmanager@bbc.com') }

      it 'shows the staff portal for managers' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Staff Portal')
      end
    end
  end
end