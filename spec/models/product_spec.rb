require 'spec_helper'

describe Product do
  
  describe 'attributes, validation and associations' do
    let(:product) { FactoryGirl.create(:product) }
    subject { product }

    it { should respond_to(:title) }
    it { should respond_to(:price) }
    it { should respond_to(:published) }
    it { should respond_to(:user) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:user_id) }
    it { should belong_to(:user) }
  end

  describe '.filter_by_title' do
    before(:each) do
      @product1 = FactoryGirl.create(:product, title: 'This is a big product')
      @product2 = FactoryGirl.create(:product, title: 'Free Smiles')
      @product3 = FactoryGirl.create(:product, title: 'big ideas')
      @product4 = FactoryGirl.create(:product, title: 'another Product')
      @filtered_result = Product.filter_by_title("product")
    end

    context 'it should find the products' do
      it 'return an array of products' do
        expect(@filtered_result).to have(2).items
      end

      it 'should include product sorted alphabetically' do
        expect(@filtered_result.sort).to match_array([@product4, @product1])
      end
    end
  end

  context 'database with four products and different prices' do
    
    before(:each) do
      @product1 = FactoryGirl.create(:product, price: 100)
      @product2 = FactoryGirl.create(:product, price: 50)
      @product3 = FactoryGirl.create(:product, price: 150)
      @product4 = FactoryGirl.create(:product, price: 30)
    end
    
    describe '.below_or_equal_to_price' do
      it 'should return an array of products filtered and sorted by price' do
        filtered_result = Product.below_or_equal_to_price(90)       
        expect(filtered_result.sort).to match_array([@product4, @product2])
      end
    end

    describe '.above_or_equal_to_price' do
      it 'should return an array of products filtered and sorted by price' do
        filtered_result = Product.above_or_equal_to_price(100)
        expect(filtered_result.sort).to match_array([@product1, @product3])
      end
    end

    describe '.recent' do
      before(:each) do
        @product1.touch
        @product2.touch
      end
      it 'should return an array of products filtered by the updated_at field' do
        expect(Product.recent).to match_array([@product2, @product1, @product4, @product3])
      end
    end
  end

  describe '.search' do
    before(:each) do
      @product1 = FactoryGirl.create(:product, title: 'This is a big product', price: 100)
      @product2 = FactoryGirl.create(:product, title: 'Free Smiles', price: 50)
      @product3 = FactoryGirl.create(:product, title: 'big ideas', price: 150)
      @product4 = FactoryGirl.create(:product, title: 'another Product', price: 30)
    end

    it 'when a title "bit product" and a price of minimum 100 is set' do
      search_array = { keyword: 'big product', min_price: 100 }
      expect(Product.search(search_array)).to match_array([@product1])
    end

    it 'when a title "product", min price is 30 and max price 150' do 
      search_array = { keyword: 'product', min_price: 30, max_price: 150 }
      expect(Product.search(search_array)).to match_array([@product1, @product4])
    end

    it 'return all the product when not input is given to the search' do
      expect(Product.search({})).to match_array([@product1, @product2, @product3, @product4])
    end

    it 'returns the products from the ids' do
      search_array = { product_ids: [@product1.id, @product2.id]}
      expect(Product.search(search_array)).to match_array([@product1, @product2])
    end
  end
end