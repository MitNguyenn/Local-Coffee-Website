RSpec.describe 'Home page', type: :feature do

  it 'allows user to visit log-in page' do
    visit '/log-in'
    expect(current_path).to eq('/log-in')
    expect(page).to have_content('Welcome Back')
  end

  it 'allows user to access beans menu' do
    visit '/'
    find('.pill-half.left').click
    expect(current_path).to eq('/coffee-beans')
    expect(page).to have_content('Our Coffee Beans')
  end

  it 'allows user to access drinks menu' do
    visit '/'
    find('.pill-half.right').click
    expect(current_path).to eq('/drinks')
    expect(page).to have_content('Our Hot Drinks')
  end

  it 'allows user to view help page' do
    visit '/'
    click_link 'Help'
    expect(current_path).to eq('/help')
    expect(page).to have_content('Request Description')
  end

  context 'when logged in as user' do 
    before(:each) { log_in_as('john@example.com', '_p_')}
    it 'displays loyalty card page' do
      visit '/loyalty-card'
      expect(current_path).to eq('/loyalty-card')
      expect(page).to have_content('Scan this QR code in store!')
    end
  end

  describe 'Staff portal access' do
    context 'when logged in as an admin' do
      before(:each) { log_in_as('admin@coffee.com', '_p_') }

      it 'shows the administrator portal' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Administrator Portal')
      end
    end

    context 'when logged in as a barista' do
      before(:each) { log_in_as('barista@coffee.com', '_p_') }

      it 'shows the barista portal' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Barista Portal')
      end
    end

    context 'when logged in as a manager' do
      before(:each) { log_in_as('manager@coffee.com', '_p_') }

      it 'shows the manager portal' do
        visit '/'
        click_link 'Staff Portal'
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Manager Portal')
      end
    end
  end
end