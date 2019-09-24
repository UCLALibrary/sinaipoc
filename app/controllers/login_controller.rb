require 'securerandom'

class LoginController < ApplicationController
  before_action :create_token

  def new
    @domain = request.domain
    @port = request.port
    @requested_path = params[:callback]
    @full_path = "http://#{@domain}:#{@port}#{@requested_path}"
  end

  def create_token
    @token = SecureRandom.uuid
    @login = Login.create(token: @token)
    @token_success = "Token created!"
  end
end
