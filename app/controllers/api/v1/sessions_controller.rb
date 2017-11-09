class Api::V1::SessionsController < ApplicationController

	def create 
		email = params[:session][:email]
		password = params[:session][:password]
		user = email.present? && User.find_by(email: email)

		if user.valid_password?(password)
			sign_in user, store: false
			user.generate_authentication_token!
			user.save
			render json: user, status: 200, location: [:api_v1, user]
		else 
			render json: { errors: 'Invalid email or password' }, status: 422
		end
	end
end
