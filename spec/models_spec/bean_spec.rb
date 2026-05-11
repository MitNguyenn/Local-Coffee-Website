RSpec.describe Bean, type: :model do 
  let(:bean) { Bean.new }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(bean).to be_valid
    end
  end
end