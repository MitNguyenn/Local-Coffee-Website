# Audit model for recording system events and changes.

class Audit < Sequel::Model(:Audits)
  set_primary_key :audit_id

end