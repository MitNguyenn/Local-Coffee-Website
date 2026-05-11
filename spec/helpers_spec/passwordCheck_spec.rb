RSpec.describe PasswordCheck do
  include described_class

  describe "#hash_password" do
    it "returns a hashed version of the password" do
      password = "my_secure_password"
      hashed_password = hash_password(password)
      expect(BCrypt::Password.new(hashed_password)).to eq(password)
    end
  end

  describe "#getPlaintextPassword" do
    it "returns the original password from the hashed version" do
      password = "my_secure_password"
      hashed_password = hash_password(password)
      plaintext_password = getPlaintextPassword(hashed_password)
      expect(plaintext_password).to eq(password)
    end
  end
end
