# Getcurrentbeans Spec file.

require 'spec_helper'

RSpec.describe GetBeans do
  include described_class

  describe '#get_bean_data' do
    context 'when the targeted bean origin exists in the seed data' do
      it 'fetches the complete production database record accurately' do
        result = get_bean_data('Ethiopian')
        
        expect(result).not_to be_nil
        expect(result[:origin]).to eq('Ethiopian')
        expect(result[:stock_mass]).not_to be_nil #random result cant check for specific value
        expect(result[:price_per_250g]).to eq(8.20)
      end
    end

    context 'when the targeted bean origin does not exist in the seed data' do
      it 'returns nil safely' do
        expect(get_bean_data('NonExistentOrigin')).to be_nil
      end
    end
  end

  describe '#get_bean_stock' do
    it 'builds a structured hash mapped cleanly by all seeded unique origins' do
      result = get_bean_stock

      expect(result.keys).to match_array(['Ethiopian', 'Brazillian', 'Arabic'])
      
      expect(result['Ethiopian'][:current_stock]).not_to be_nil #see above in L13
      expect(result['Ethiopian'][:price_per_250g]).to eq(8.20)
      
      expect(result['Brazillian'][:current_stock]).not_to be_nil #see L13
      expect(result['Brazillian'][:price_per_250g]).to eq(6.35)

      expect(result['Arabic'][:current_stock]).not_to be_nil #see L13
      expect(result['Arabic'][:price_per_250g]).to eq(4.75)
    end
  end

  describe '#update_bean_stock' do
    let(:new_data) do
      {
        new_origin: 'Premium Ethiopian',
        new_stock: 22.5,
        new_price_per_250g: 9.50
      }
    end

    context 'when targeting a valid seeded bean profile' do
      it 'updates all field rows successfully and returns true' do
        # Target the seeded 'Ethiopian' record
        execution = update_bean_stock('Ethiopian', new_data)
        
        expect(execution).to be true
        
        # Verify the adjustments persist cleanly in the underlying DB layer
        updated_record = DB[:Beans].where(origin: 'Premium Ethiopian').first
        expect(updated_record).not_to be_nil
        expect(updated_record[:stock_mass]).to eq(22.5)
        expect(updated_record[:price_per_250g]).to eq(9.50)
        
        # Verify the original identifier string no longer tracks records
        expect(DB[:Beans].where(origin: 'Ethiopian').first).to be_nil
      end
    end

    context 'when targeting an invalid bean profile out of bounds from seed entries' do
      it 'makes zero table modifications and returns false' do
        initial_count = DB[:Beans].count
        execution = update_bean_stock('NonExistentOrigin', new_data)
        
        expect(execution).to be false
        expect(DB[:Beans].count).to eq(initial_count)
      end
    end
  end
end