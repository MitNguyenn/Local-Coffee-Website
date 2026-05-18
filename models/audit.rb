# Audit model for recording system events and changes.

class Audit < Sequel::Model(:Audits)
  # Ensure the primary key matches your PDF
  set_primary_key :audit_id

end