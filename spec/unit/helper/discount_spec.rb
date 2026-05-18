# Discount Spec file.

require 'spec_helper'

RSpec.describe Discounts do
  # Include the module directly into the example group context
  include described_class

  describe '#get_current_discounts' do
    it 'reads records from the database and structures them correctly' do
      # Insert a unique test discount alongside existing seeds
      discount_id = DB[:Discounts].insert(discount_name: 'Custom RSpec Discount', discount_multiplier: 0.75)

      result = get_current_discounts

      expect(result).to have_key('Custom RSpec Discount')
      expect(result['Custom RSpec Discount']).to eq({
        id: discount_id,
        multiplier: 0.75
      })
    end
  end

  describe '#update_discount' do
    context 'with a valid record id' do
      it 'updates properties and returns true' do
        discount_id = DB[:Discounts].insert(discount_name: 'To Be Updated', discount_multiplier: 1.0)
        payload = { discount_id: discount_id, discount_name: 'Successfully Updated', discount_mult: '0.60' }
        
        expect(update_discount(payload)).to be true

        updated_row = DB[:Discounts].first(discount_id: discount_id)
        expect(updated_row[:discount_name]).to eq('Successfully Updated')
        expect(updated_row[:discount_multiplier]).to eq(0.60)
      end
    end

    context 'with an invalid record id' do
      it 'leaves current data intact and returns false' do
        payload = { discount_id: 99_999_999, discount_name: 'Non Existent', discount_mult: 0.50 }
        
        expect(update_discount(payload)).to be false
      end
    end
  end

  describe '#create_discount' do
    it 'inserts a new record with correct type mapping' do
      create_discount('New RSpec Promo', '0.80')

      created_record = DB[:Discounts].first(discount_name: 'New RSpec Promo')
      expect(created_record).not_to be_nil
      expect(created_record[:discount_multiplier]).to eq(0.80)
    end
  end

  describe '#delete_discount' do
    it 'removes the correct record and returns true' do
      discount_id = DB[:Discounts].insert(discount_name: 'To Be Deleted', discount_multiplier: 0.90)

      expect(delete_discount(discount_id)).to be true
      expect(DB[:Discounts].first(discount_id: discount_id)).to be_nil
    end

    it 'returns false if the record id is missing' do
      expect(delete_discount(99_999_999)).to be false
    end
  end
end