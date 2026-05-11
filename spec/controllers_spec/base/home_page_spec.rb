RSpec.describe 'Home page', type: :feature do 
    describe 'Clicking beans menu button' do
        it 'allows user to access beans menu' do
            visit '/'
            click_link 'Beans'
            save_and_open_page
            expect(current_path).to eq('/coffee-beans')
            expect(page).to have_content('Our Coffee Beans')
        end
    end
end