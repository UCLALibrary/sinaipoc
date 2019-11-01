### TEST VERSION
###   localhost:3030
###   click button
###   log into EMEL
###   the home page will display
###     Sinai Digital Library - Proof of Concept
###   view debug cookies A-G
###     debug cookies A-F show packed, unpacked and repacked values are shown for the two SinaiPOC cookies
###       the packed and repacked values should match
###     debug cookie G shows the unencrypted authorization string
###       the unecrypted authetication string should display
###
###   e.g.
###   A_TEST_iv_already_packed   %24%7Cw%CA%B6%ED%9F%7B6%96%EF%D5z%EB%5D6
###   B_TEST_iv_unPacked         247C77CAB6ED9F7B3696EFD57AEB5D36
###   C_TEST_iv_rePacked         %24%7Cw%CA%B6%ED%9F%7B6%96%EF%D5z%EB%5D6
###   D_TEST_auth_already_packed %D1%FF%14%F2%DBd%BA%85M%B8%91%A6%9B%FC%81%1C-%DC%0B%DE%DAI%EF%C0%05%0F%5D%89%28Kt9
###   E_TEST_auth_unpacked       D1FF14F2DB64BA854DB891A69BFC811C2DDC0BDEDA49EFC0050F5D89284B7439
###   F_TEST_auth_RePacked       %D1%FF%14%F2%DBd%BA%85M%B8%91%A6%9B%FC%81%1C-%DC%0B%DE%DAI%EF%C0%05%0F%5D%89%28Kt9
###   G_TEST_unencrypted         Authenticated+2019-11-01

# frozen_string_literal: true
require 'openssl'

class ApplicationController < ActionController::Base
  before_action :sinai_authenticated?

  def sinai_authenticated?
    @path_check = ''
    
    # Checks to see if we are on the Login page and do nothing
    if request.fullpath.include?(login_path)
      @path_check = request.fullpath.include?(login_path)
    else
      if has_cookie?
        # do nothing
        'has_cookie You have a valid cookie that is allowing you to browse the Sinai Digital Library.'
      elsif has_token?
        # user has a token so we then need to set the cookie based on the fact that they have a token in the database
        set_auth_cookie
        set_iv_cookie
        'has_token You have a valid cookie that is allowing you to browse the Sinai Digital Library.'
        test_iv_cookie
        test_auth_cookie
        test_encrypted_string
      else
        redirect_to "/login?callback=#{request.original_url}"
      end
    end
  end

  def has_cookie?
    # Does user have the sinai cookie?
    @has_cookie = cookies[:sinai_authenticated]
  end

  def has_token?
    # Does user have the sinai token in the database?
    params[:token].present? && Login.find_by(token: params[:token])
  end

  def set_session_cookie
    session[:sinai_authenticated_test] = "authenticated"
  end

  def set_auth_cookie
    @encryptd_str = create_encrypted_string
    cookies[:sinai_authenticated] = {
      value: @cipher_text_unPacked,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
  end

  def set_iv_cookie
    @iv_unPacked = @iv.unpack('H*')[0].upcase
    cookies[:initialization_vector] = {
      value: @iv_unPacked,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
  end

  def create_encrypted_string
    todays_date = Time.zone.today
    cipher = OpenSSL::Cipher::AES256.new :CBC
    cipher.encrypt
    @iv = cipher.random_iv
    cipher.key = ENV['CIPHER_KEY']
    cipher.iv = @iv
    @cipher_text_packed = cipher.update("Authenticated #{todays_date}") + cipher.final
    @cipher_text_unPacked = @cipher_text_packed.unpack('H*')[0].upcase
  end
end

def test_iv_cookie
  cookies[:A_TEST_iv_already_packed] = {
    value: @iv,
    expires: Time.now + 90.days,
    domain: ENV['DOMAIN']
  }
  @test_iv_unPacked = cookies[:initialization_vector]
  cookies[:B_TEST_iv_unPacked] = {
    value: @test_iv_unPacked,
    expires: Time.now + 90.days,
    domain: ENV['DOMAIN']
  }
  @test_iv_rePacked = [@test_iv_unPacked].pack('H*').unpack('C*').pack('c*')
  cookies[:C_TEST_iv_rePacked] = {
    value: @test_iv_rePacked,
    expires: Time.now + 90.days,
    domain: ENV['DOMAIN']
  }

  def test_auth_cookie
    cookies[:D_TEST_auth_already_packed] = {
      value: @cipher_text_packed,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
    @cipher_text_unPacked = cookies[:sinai_authenticated]
    cookies[:E_TEST_auth_unpacked] = {
      value: @cipher_text_unPacked,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
    @authRePacked = [@cipher_text_unPacked].pack('H*').unpack('C*').pack('c*')
    cookies[:F_TEST_auth_RePacked] = {
      value: @authRePacked,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
  end

  def test_encrypted_string
    decipher = OpenSSL::Cipher::AES256.new :CBC
    decipher.decrypt
    @test_iv_unPacked = cookies[:initialization_vector]
    @test_iv_rePacked = [@test_iv_unPacked].pack('H*').unpack('C*').pack('c*')
    decipher.iv = @test_iv_rePacked
    decipher.key = ENV['CIPHER_KEY']
    @test_auth_unPacked = cookies[:sinai_authenticated]
    test_auth_rePacked = [@test_auth_unPacked].pack('H*').unpack('C*').pack('c*')
    @test_unencrypted = decipher.update(test_auth_rePacked) + decipher.final

    cookies[:G_TEST_unencrypted] = {
      value: @test_unencrypted,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
  end
end
