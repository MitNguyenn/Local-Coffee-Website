RSpec.describe AccountRecency do
  describe "#check_account_recency" do
    it "flags accounts that haven't logged in for 30 days" do
      #init dummy account with Recent_Login > 30 days ago
      #call attempt_flag_account with that account's user_id
      #expect that account is flagged
      #expect that account's Flagged_At is set to current time
      DB[:Accounts].insert(UserID: 1, Recent_Login: Time.now - (31 * 24 * 60 * 60), Flagged: false, Flagged_At: nil, Suspended: false)
      attempt_flag_account(1)
      account = DB[:Accounts].where(UserID: 1).first
      expect(account[:Flagged]).to eq(true)
      expect(account[:Flagged_At]).not_to be_nil
    end

    it "suspends accounts that have been flagged for more than 5 days" do
      #setup 2 accounts, one flagged for > 5 days and one flagged for < 5 days
      DB[:Accounts].insert(UserID: 2, Recent_Login: Time.now - (31 * 24 * 60 * 60), Flagged: true, Flagged_At: Time.now - (6 * 24 * 60 * 60), Suspended: false)
      DB[:Accounts].insert(UserID: 3, Recent_Login: Time.now - (31 * 24 * 60 * 60), Flagged: true, Flagged_At: Time.now - (4 * 24 * 60 * 60), Suspended: false)
      #call attempt_suspend_account for both accounts
      attempt_suspend_account(2)
      attempt_suspend_account(3)
      #expect account flagged for > 5 days to be suspended
      account2 = DB[:Accounts].where(UserID: 2).first
      expect(account2[:Suspended]).to eq(true)
      #expect account flagged for < 5 days to not be suspended
      account3 = DB[:Accounts].where(UserID: 3).first
      expect(account3[:Suspended]).to eq(false)
    end
  end
end

#idefk man