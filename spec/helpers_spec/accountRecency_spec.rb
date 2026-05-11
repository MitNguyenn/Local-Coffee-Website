require 'spec_helper'

RSpec.describe AccountRecency do
  # Helper to clean the DB before each test to prevent ID collisions
  before do
    DB[:Accounts].delete
  end

  describe "#check_account_recency" do
    it "flags accounts that haven't logged in for 30 days" do
      # Setup dummy account with all required database fields
      DB[:Accounts].insert(
        UserID: 1,
        email: 'user1@example.com',
        first_name: 'Test',
        last_name: 'User',
        hashed_password: 'password123456', # Meets 12 char requirement
        Recent_Login: Time.now - (31 * 24 * 60 * 60),
        Flagged: false,
        Flagged_At: nil,
        Suspended: false
      )

      attempt_flag_account(1)

      account = DB[:Accounts].where(UserID: 1).first
      expect(account[:Flagged]).to eq(true)
      expect(account[:Flagged_At]).not_to be_nil
    end

    it "suspends accounts that have been flagged for more than 5 days" do
      # Account A: Flagged 6 days ago (Should be suspended)
      DB[:Accounts].insert(
        UserID: 2,
        email: 'user2@example.com',
        first_name: 'Old',
        last_name: 'Flag',
        password: 'password123456',
        Recent_Login: Time.now - (31 * 24 * 60 * 60),
        Flagged: true,
        Flagged_At: Time.now - (6 * 24 * 60 * 60),
        Suspended: false
      )

      # Account B: Flagged 4 days ago (Should NOT be suspended)
      DB[:Accounts].insert(
        UserID: 3,
        email: 'user3@example.com',
        first_name: 'New',
        last_name: 'Flag',
        password: 'password123456',
        Recent_Login: Time.now - (31 * 24 * 60 * 60),
        Flagged: true,
        Flagged_At: Time.now - (4 * 24 * 60 * 60),
        Suspended: false
      )

      attempt_suspend_account(2)
      attempt_suspend_account(3)

      account2 = DB[:Accounts].where(UserID: 2).first
      expect(account2[:Suspended]).to eq(true)

      account3 = DB[:Accounts].where(UserID: 3).first
      expect(account3[:Suspended]).to eq(false)
    end
  end
end
