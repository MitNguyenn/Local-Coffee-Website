# Helper methods for tracking account recency and login behavior.

module AccountRecency
  def attempt_flag_account(user_id)
    account = DB[:Accounts].where(user_id: user_id).first
    if account
      last_login = account[:recent_login]
      if last_login
        days_since_last_login = (Time.now - last_login) / (60 * 60 * 24)
        if days_since_last_login > 30
          DB[:Accounts].where(user_id: user_id).update(flagged: true)
          DB[:Accounts].where(user_id: user_id).update(flagged_at: Time.now)
        end
      end
    end
  end

  def attempt_suspend_account(user_id)
    account = DB[:Accounts].where(user_id: user_id).first
    if account
      last_login = account[:recent_login]
      if last_login
        days_since_last_login = (Time.now - last_login) / (60 * 60 * 24)
        if account[:flagged]
          if account[:flagged_at]
            days_since_flagged = (Time.now - account[:flagged_at]) / (60 * 60 * 24)
            if days_since_flagged > 5
              DB[:Accounts].where(user_id: user_id).update(suspended: true)
            end
          end
        end
      end
    end
  end
end