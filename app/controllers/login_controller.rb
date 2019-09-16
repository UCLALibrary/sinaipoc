require 'securerandom'

class LoginController < ApplicationController
  def new
    @token = SecureRandom.uuid
    @login = Login.create(token: @token)
  end

  def mock_sinai
    puts params
  end
end
