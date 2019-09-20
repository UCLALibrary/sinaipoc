require 'securerandom'

class LoginController < ApplicationController
  before_action :create_token

  def new
  end

  def create_token
    @token = SecureRandom.uuid
    @login = Login.create(token: @token)
    @token_success = "Token created!"
  end
end
