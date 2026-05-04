module AccountRecency
  def attempt_flag_account(user_id)
    account = DB[:Accounts].where(UserID: user_id).first
    if account
      last_login = account[:Recent_Login]
      if last_login
        days_since_last_login = (Time.now - last_login) / (60 * 60 * 24)
        if days_since_last_login > 30
          DB[:Accounts].where(UserID: user_id).update(Flagged: true)
        end
      end
    end
  end

  def attempt_suspend_account(user_id)
    account = DB[:Accounts].where(UserID: user_id).first
    if account
      last_login = account[:Recent_Login]
      if last_login
        days_since_last_login = (Time.now - last_login) / (60 * 60 * 24)
        if days_since_last_login > 60
          DB[:Accounts].where(UserID: user_id).update(Suspended: true)
        end
      end
    end
  end
end