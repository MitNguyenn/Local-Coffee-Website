RSpec.describe 'Home page', type: :feature do

  context "Given an anonymous visitor on the application" do
    context "When attempting to open the log in page directly" do
      it "Then loads the login path showing welcoming messages" do
        visit '/log-in'
        
        expect(current_path).to eq('/log-in')
        expect(page).to have_content('Welcome Back')
      end
    end

    context "When interacting with navigation elements on the home view" do
      it "Then opens the beans menu when clicking the left pill selector" do
        visit '/'
        find('.pill-half.left').click
        
        expect(current_path).to eq('/coffee-beans')
        expect(page).to have_content('Our Coffee Beans')
      end

      it "Then opens the drinks menu when clicking the right pill selector" do
        visit '/'
        find('.pill-half.right').click
        
        expect(current_path).to eq('/drinks')
        expect(page).to have_content('Our Hot Drinks')
      end

      it "Then transfers focus onto the support help desk via text links" do
        visit '/'
        click_link 'Help'
        
        expect(current_path).to eq('/help')
        expect(page).to have_content('Request description')
      end

      it "Then displays the active promotions collection via text links" do
        visit '/'
        click_link 'Discounts'
        
        expect(current_path).to eq('/discounts')
        expect(page).to have_content('Our Current Discounts!')
      end

      it "Then drops them back to the log-in page when unauthorized links are used" do
        visit '/'
        click_link 'Staff Portal'
        
        expect(current_path).to eq('/log-in')
      end
    end
  end

  context 'Given a user authenticated as a regular customer' do 
    before(:each) do 
      log_in_as('testcust@bbc.com', 'testcust@bbc.com')
    end

    context "When exploring customer portal links from the main index" do
      it 'Then renders the dynamic reward stamp QR template block layout' do
        visit '/'
        click_link 'Loyalty Card'
        
        expect(current_path).to eq('/loyalty-card')
        expect(page).to have_content('Scan this QR code in store!')
      end

      it 'Then routes down onto active customer purchase tracking summaries' do
        visit '/'
        click_link 'My Orders'
        
        expect(current_path).to eq('/my-orders')
        expect(page).to have_content('Live Orders')
      end

      it 'Then reveals personal account preference management form screens' do
        visit '/'
        click_link 'Account settings'
        
        expect(current_path).to eq('/account-settings')
        expect(page).to have_content('Personal Details')
      end

      it 'Then prevents access to backoffice utilities dropping users onto root' do
        visit '/'
        click_link 'Staff Portal'
        
        expect(current_path).to eq('/')
      end
    end
  end

  context 'Given a user authenticated as an administrator' do
    before(:each) do 
      log_in_as('testadmin@bbc.com', 'testadmin@bbc.com') 
    end

    context 'When requesting access to the staff operations node link' do
      it 'Then routes securely into the master dashboard management panel' do
        visit '/'
        click_link 'Staff Portal'
        
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Staff Portal')
      end
    end
  end

  context 'Given a user authenticated as a barista staff employee' do
    before(:each) do 
      log_in_as('testbarista@bbc.com', 'testbarista@bbc.com') 
    end

    context 'When requesting access to the staff operations node link' do
      it 'Then routes securely into the master dashboard management panel' do
        visit '/'
        click_link 'Staff Portal'
        
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Staff Portal')
      end
    end
  end

  context 'Given a user authenticated as a store manager' do
    before(:each) do 
      log_in_as('testmanager@bbc.com', 'testmanager@bbc.com') 
    end

    context 'When requesting access to the staff operations node link' do
      it 'Then routes securely into the master dashboard management panel' do
        visit '/'
        click_link 'Staff Portal'
        
        expect(current_path).to eq('/staff-portal')
        expect(page).to have_content('Staff Portal')
      end
    end
  end
end