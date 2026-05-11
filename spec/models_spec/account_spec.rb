RSpec.describe Account type: :model do
  let(:account) { Account.new(email: "testemail123@gmail.com", AccountType: "Admin") }  
  
  describe "validations" do
    it "is valid with valid attributes" do
      expect(account).to be_valid
    end

    it "is invalid without an email" do
      account.email = nil
      expect(account).not_to be_valid
      expect(account.errors[:email]).to include("is required")
    end

    it "is invalid without an AccountType" do
      account.AccountType = nil
      expect(account).not_to be_valid
      expect(account.errors[:AccountType]).to include("must be assigned")
    end
  end

  describe "#password=" do
    it "hashes the password before saving" do
      raw_password = "mysecretpassword"
      account.password = raw_password
      expect(account.hashed_password).not_to eq(raw_password)
      expect(BCrypt::Password.new(account.hashed_password)).to eq(raw_password)
    end
  end
end