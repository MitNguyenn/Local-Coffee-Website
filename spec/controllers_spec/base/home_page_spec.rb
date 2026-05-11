RSpec.describe 'Home page', type: :feature do 
    describe 'Clicking beans menu button' do
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

        it 'allows user to access staff portal' do
            visit '/'
            click_link 'Staff Portal'
            expect(current_path).to eq('/staff-portal')
            expect(page).to have_content('Portal')
        end
    end
end