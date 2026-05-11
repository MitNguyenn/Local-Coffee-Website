module AccountRecency
  def attempt_flag_account(user_id)
    account = DB[:Accounts].where(UserID: user_id).first
    if account
      last_login = account[:Recent_Login]
      if last_login
        days_since_last_login = (Time.now - last_login) / (60 * 60 * 24)
        if days_since_last_login > 30
          DB[:Accounts].where(UserID: user_id).update(Flagged: true)
          DB[:Accounts].where(UserID: user_id).update(Flagged_At: Time.now)
        end
      end
    end
  end

#Suspend Logic is:
#Account flagged if not logged in for 6 months
#Account suspended if flagged for > 5 days 

  def attempt_suspend_account(user_id)
    account = DB[:Accounts].where(UserID: user_id).first
    if account
      last_login = account[:Recent_Login]
      if last_login
        days_since_last_login = (Time.now - last_login) / (60 * 60 * 24)
        if account[:Flagged]
          if account[:Flagged_At]
            days_since_flagged = (Time.now - account[:Flagged_At]) / (60 * 60 * 24)
            if days_since_flagged > 5
              DB[:Accounts].where(UserID: user_id).update(Suspended: true)
            end
          end
        end
      end
    end
  end
end