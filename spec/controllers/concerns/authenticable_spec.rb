require 'spec_helper'

class Authentication
	include Authenticable
end

describe Authenticable do
	let(:authentication) { Authentication.new }
	subject { authentication }

	describe '#current_user' do 
		before(:each) do
			@user = FactoryGirl.create(:user)
			request.headers['Authorization'] = @user.auth_token
			authentication.stub(:request).and_return(request)
		end

		it 'returns the user auth_token' do
			expect(authentication.current_user.auth_token).to eql @user.auth_token
		end
	end

	describe 'authenticate with token' do
		before(:each) do
			@user = FactoryGirl.create(:user)
			authentication.stub(:current_user).and_return(nil)
			response.stub(:body).and_return({'errors' => 'Not Authenticated'}.to_json)
			response.stub(:response_code).and_return(401)
			authentication.stub(:response).and_return(response)
		end

		it 'should return an error messages' do
			expect(json_response[:errors]).to eql('Not Authenticated')
		end	

		it { should respond_with 401}
	end
end