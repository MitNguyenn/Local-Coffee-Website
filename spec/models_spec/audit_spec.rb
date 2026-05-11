RSpec.describe Audit, type: :model do
  it 'has the correct primary key' do
    expect(Audit.primary_key).to eq(:AuditID)
  end
end
