RSpec.describe 'Staff Portal', type: :feature do
    before(:each) {visit '/staff-portal'}

    context "when logged in as a barista" do
        before(:each) {log_in_as('testbarista@bbc.com', 'testpass')}
        it 'shows order management link' do
            expect(page).to have_content('Order Management')
            click_link 'Order Management'
            expect(current_path).to eq('/order-management/barista')
        end
    end
end