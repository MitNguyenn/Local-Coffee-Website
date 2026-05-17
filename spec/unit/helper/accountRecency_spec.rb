require 'spec_helper'

RSpec.describe AccountRecency, type: :helper do
  include described_class

  # We use the user_id 10000001 seeded in spec_functions.rb
  let(:user_id) { 11 }

  describe "#check_account_recency" do
    it "flags accounts that haven't logged in for 30 days" do
      attempt_flag_account(user_id)

      account = DB[:Accounts].where(user_id: user_id).first
      expect(account[:flagged]).to eq(true)
      expect(account[:flagged_at]).not_to be_nil
    end

    it "suspends accounts that have been flagged for more than 5 days" do
      # Update seeded user to look like they've been flagged for 6 days
      DB[:Accounts].where(user_id: user_id).update(
        flagged: true,
        flagged_at: Time.now - (6 * 24 * 60 * 60),
        suspended: false
      )

      attempt_suspend_account(user_id)

      account = DB[:Accounts].where(user_id: user_id).first
      expect(account[:suspended]).to eq(true)
    end

    it "does not suspend accounts flagged for only 4 days" do
      # Update seeded user to look like they've been flagged for only 4 days
      DB[:Accounts].where(user_id: user_id).update(
        flagged: true,
        flagged_at: Time.now - (4 * 24 * 60 * 60),
        suspended: false
      )

      attempt_suspend_account(user_id)

      account = DB[:Accounts].where(user_id: user_id).first
      expect(account[:suspended]).to eq(false)
    end
  end
end
