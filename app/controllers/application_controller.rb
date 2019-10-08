# frozen_string_literal: true
require 'openssl'

class ApplicationController < ActionController::Base
  before_action :sinai_authenticated?

  def sinai_authenticated?
    @path_check = ''
    @cookie_created = ''
    
    # Checks to see if we are on the Login page and do nothing
    if request.fullpath.include?(login_path)
      @path_check = request.fullpath.include?(login_path)
    else
      @popsicle = 'Popsicle'
      if has_cookie?
        # do nothing
        'has_cookie You have a valid cookie that is allowing you to browse the Sinai Digital Library.'
      elsif has_token?
        # user has a token so we then need to set the cookie based on the fact that they have a token in the database
        set_cookie
        set_iv_cookie
        'has_token You have a valid cookie that is allowing you to browse the Sinai Digital Library.'
      else
        redirect_to "/login?callback=#{request.original_url}"
      end
    end
  end

  def has_token?
    # Does user have the sinai token in the database?
    params[:token].present? && Login.find_by(token: params[:token])
  end

  def set_cookie
    @encryptd_str = create_encrypted_string
    cookies[:sinai_authenticated] = {
      value: @cipher_text,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
    @cookie_created = @encryptd_str
  end

  def has_cookie?
    # Does user have the sinai cookie set to true?
    @has_cookie = cookies[:sinai_authenticated]
  end

  def set_iv_cookie
    cookies[:initialization_vector] = { value: @iv }
  end

  def create_encrypted_string
    todays_date = Time.zone.today
    cipher = OpenSSL::Cipher::AES256.new :CBC
    cipher.encrypt
    @iv = cipher.random_iv
    # cipher.key = OpenSSL::Random.random_bytes(32)
    cipher.key = ENV['CIPHER_KEY']
    @cipher_text = cipher.update("Authenticated #{todays_date}") + cipher.final
  end
end

# Share with Kevin/Hardy

# https://ruby-doc.org/stdlib-2.4.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-random_key
# https://medium.com/@Bakku1505/playing-with-symmetric-encryption-algorithms-in-ruby-8652f105341e

# def decrypt_string
#   decipher = OpenSSL::Cipher::AES256.new :CBC
#   decipher.decrypt
#   decipher.iv = ENV['CIPHER_INITIALIZATION_VECTOR']
#   decipher.key = ENV['CIPHER_KEY']
#   decipher.update(@cipher_text) + decipher.final # @cipher_text
# end
# CIPHER_KEY
