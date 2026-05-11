require 'spec_helper'

RSpec.describe AccountRecency do
  include described_class

  # We use the UserID 10000001 seeded in spec_functions.rb
  let(:user_id) { 10000001 }

  describe "#check_account_recency" do
    it "flags accounts that haven't logged in for 30 days" do
      # Modify seeded user to be old
      DB[:Accounts].where(UserID: user_id).update(
        Recent_Login: Time.now - (31 * 24 * 60 * 60),
        Flagged: false
      )

      attempt_flag_account(user_id)

      account = DB[:Accounts].where(UserID: user_id).first
      expect(account[:Flagged]).to eq(true)
      expect(account[:Flagged_At]).not_to be_nil
    end

    it "suspends accounts that have been flagged for more than 5 days" do
      # Update seeded user to look like they've been flagged for 6 days
      DB[:Accounts].where(UserID: user_id).update(
        Flagged: true,
        Flagged_At: Time.now - (6 * 24 * 60 * 60),
        Suspended: false
      )

      attempt_suspend_account(user_id)

      account = DB[:Accounts].where(UserID: user_id).first
      expect(account[:Suspended]).to eq(true)
    end

    it "does not suspend accounts flagged for only 4 days" do
      # Update seeded user to look like they've been flagged for only 4 days
      DB[:Accounts].where(UserID: user_id).update(
        Flagged: true,
        Flagged_At: Time.now - (4 * 24 * 60 * 60),
        Suspended: false
      )

      attempt_suspend_account(user_id)

      account = DB[:Accounts].where(UserID: user_id).first
      expect(account[:Suspended]).to eq(false)
    end
  end
end
