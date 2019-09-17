require 'securerandom'

class LoginController < ApplicationController
  def new
    if params[:token].present?
      validate_token
    else
      @token = SecureRandom.uuid
      @login = Login.create(token: @token)
      @token_success = "Token created!"
    end
  end

  def validate_token
    if Login.find_by(token: params[:token])
      flash[:success] = 'You can now see the images!'
      redirect_to '/'
    else
      flash[:error] = 'Your session has expired'
      redirect_to '/login'
    end
  end
end
