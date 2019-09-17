require 'securerandom'

class LoginController < ApplicationController
  def new
    if params[:token].present?
      @tsuccess="I see the token: #{params[:token]}"
      validate_token
    else
      @token = SecureRandom.uuid
      @login = Login.create(token: @token)
      @tsuccess="No token"
    end
  end

  def mock_sinai
    puts params
  end

  def login_response
  end

  def validate_token
    # comparing token from GET to tokens in db
    users_token=params[:token]
    if Login.find_by(token: params[:token])
      @dbreturn="hurray"
      redirect_to '/'
      flash[:success]='you can now see the images'
    else
      @dbreturn="Your sessions has expired - please click on the <em>Login</em> button"
      redirect_to '/login'
      #flash[:success]='something funny'
    end
  end
end


###     @tsuccess="I see the token: #{params[:token]}" if params[:token].present? 