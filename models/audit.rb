class Audit < Sequel::Model(:Audits)
  # Ensure the primary key matches your PDF
  set_primary_key :audit_id

end