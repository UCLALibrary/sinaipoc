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
      if has_cookie?
        # do nothing
        'has_cookie You have a valid cookie that is allowing you to browse the Sinai Digital Library.'
      elsif has_token?
        # user has a token so we then need to set the cookie based on the fact that they have a token in the database
        set_cookie
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
    cookies[:sinai_authenticated] = {
      value: "authenticated",
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
    @cookie_created = "authenticated"
  end

  def has_cookie?
    # Does user have the sinai cookie set to true?
    @has_cookie = cookies[:sinai_authenticated]
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
