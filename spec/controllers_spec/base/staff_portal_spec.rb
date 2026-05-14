RSpec.describe 'Staff Portal', type: :feature do

    context "when logged in as a barista" do
        before(:each) {
            log_in_as('testbarista@bbc.com', 'testpass')
            visit '/staff-portal'
        }

        it 'shows order management link and clicks through to correct page' do
            click_link 'Barista Order Management'
            expect(current_path).to eq('/order-management/barista')
            expect(page).to have_content('Barista Order Controls')
        end
        it 'shows place user order link and clicks through to correct page' do
            click_link 'Place User Order'
            expect(current_path).to eq('/place-order/find-user')
            expect(page).to have_content('Place Order - Select Customer')
        end 
        it 'shows place loyalty cards link and clicks through to correct page' do
            click_link 'Loyalty Cards'
            expect(current_path).to eq('/manage-loyalty-cards')
            expect(page).to have_content('Manage Loyalty Cards')
        end
        it 'shows user tickets link and clicks through to correct page' do
            click_link 'User Tickets'
            expect(current_path).to eq('/user-tickets')
            expect(page).to have_content('Open Tickets')
        end
        it 'shows refunds link and clicks through to correct page' do
            click_link 'Refunds'
            expect(current_path).to eq('/refund-tickets')
            expect(page).to have_content('Open Refunds')
        end
        it 'shows daily summary link and clicks through to correct page' do
            click_link 'Daily Summary'
            expect(current_path).to eq('/daily-summary')
            expect(page).to have_content('Daily Summary')
            expect(page).to have_content('Total Sales')
        end
    end

    context "when logged in as a manager" do
        before(:each) {
            log_in_as('testmanager@bbc.com', 'testpass')
            visit '/staff-portal'
        }

        it 'shows order management link and clicks through to correct page' do
            click_link 'Barista Order Management'
            expect(current_path).to eq('/order-management/barista')
            expect(page).to have_content('Barista Order Controls')
        end
        it 'shows place user order link and clicks through to correct page' do
            click_link 'Place User Order'
            expect(current_path).to eq('/place-order/find-user')
            expect(page).to have_content('Place Order - Select Customer')
        end 
        it 'shows place loyalty cards link and clicks through to correct page' do
            click_link 'Loyalty Cards'
            expect(current_path).to eq('/manage-loyalty-cards')
            expect(page).to have_content('Manage Loyalty Cards')
        end
        it 'shows user tickets link and clicks through to correct page' do
            click_link 'User Tickets'
            expect(current_path).to eq('/user-tickets')
            expect(page).to have_content('Open Tickets')
        end
        it 'shows refunds link and clicks through to correct page' do
            click_link 'Refunds'
            expect(current_path).to eq('/refund-tickets')
            expect(page).to have_content('Open Refunds')
        end
        it 'shows daily summary link and clicks through to correct page' do
            click_link 'Daily Summary'
            expect(current_path).to eq('/daily-summary')
            expect(page).to have_content('Daily Summary')
            expect(page).to have_content('Total Sales')
        end
        it 'shows metrics link and clicks through to correct page' do
            click_link 'Metrics'
            expect(current_path).to eq('/metrics')
            expect(page).to have_content('Managerial Analytics')
        end
        it 'shows metrics link and clicks through to correct page' do
            click_link 'Metrics'
            expect(current_path).to eq('/metrics')
            expect(page).to have_content('Managerial Analytics')
        end
        it 'shows bean stock management link and clicks through to correct page' do
            click_link 'Bean Stocks'
            expect(current_path).to eq('/bean-stock-management')
            expect(page).to have_content('Ethiopian')
            expect(page).to have_content('Brazillian')
            expect(page).to have_content('Arabic')
        end
        it 'shows discount management link and clicks through to correct page' do
            click_link 'Discount Management'
            expect(current_path).to eq('/manage-discounts')
            expect(page).to have_content('Manage Store Discounts')
        end
    end

    context "when logged in as an admin" do
        before(:each) {
            log_in_as('testadmin@bbc.com', 'testpass')
            visit '/staff-portal'
        }

        it 'shows order management link and clicks through to correct page' do
            click_link 'Barista Order Management'
            expect(current_path).to eq('/order-management/barista')
            expect(page).to have_content('Barista Order Controls')
        end
        it 'shows place user order link and clicks through to correct page' do
            click_link 'Place User Order'
            expect(current_path).to eq('/place-order/find-user')
            expect(page).to have_content('Place Order - Select Customer')
        end 
        it 'shows place loyalty cards link and clicks through to correct page' do
            click_link 'Loyalty Cards'
            expect(current_path).to eq('/manage-loyalty-cards')
            expect(page).to have_content('Manage Loyalty Cards')
        end
        it 'shows user tickets link and clicks through to correct page' do
            click_link 'User Tickets'
            expect(current_path).to eq('/user-tickets')
            expect(page).to have_content('Open Tickets')
        end
        it 'shows refunds link and clicks through to correct page' do
            click_link 'Refunds'
            expect(current_path).to eq('/refund-tickets')
            expect(page).to have_content('Open Refunds')
        end
        it 'shows daily summary link and clicks through to correct page' do
            click_link 'Daily Summary'
            expect(current_path).to eq('/daily-summary')
            expect(page).to have_content('Daily Summary')
            expect(page).to have_content('Total Sales')
        end
        it 'shows metrics link and clicks through to correct page' do
            click_link 'Metrics'
            expect(current_path).to eq('/metrics')
            expect(page).to have_content('Managerial Analytics')
        end
        it 'shows metrics link and clicks through to correct page' do
            click_link 'Metrics'
            expect(current_path).to eq('/metrics')
            expect(page).to have_content('Managerial Analytics')
        end
        it 'shows bean stock management link and clicks through to correct page' do
            click_link 'Bean Stocks'
            expect(current_path).to eq('/bean-stock-management')
            expect(page).to have_content('Ethiopian')
            expect(page).to have_content('Brazillian')
            expect(page).to have_content('Arabic')
        end
        it 'shows discount management link and clicks through to correct page' do
            click_link 'Discount Management'
            expect(current_path).to eq('/manage-discounts')
            expect(page).to have_content('Manage Store Discounts')
        end
        it 'shows manage user accounts link and clicks through to correct page' do
            click_link 'Manage User Accounts'
            expect(current_path).to eq('/manage-accounts')
            expect(page).to have_content('Account Management')
        end
        it 'shows manage employee accounts link and clicks through to correct page' do
            click_link 'Manage Employee Accounts'
            expect(current_path).to eq('/employee-accounts')
            expect(page).to have_content('Account Management')
        end
        it 'shows  link and clicks through to correct page' do
            click_link 'Flagged Accounts'
            expect(current_path).to eq('/flagged-accounts')
            expect(page).to have_content('Flagged Accounts')
        end
        it 'shows  link and clicks through to correct page' do
            click_link 'Admin Order Management'
            expect(current_path).to eq('/order-management/administrator')
            expect(page).to have_content('Admin Order Controls')
        end
    end
end