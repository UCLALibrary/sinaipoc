class ApplicationController < ActionController::Base
  before_action :sinai_authenticated?

  def sinai_authenticated?
    @path_check = ''
    @cookie_created = ''
    
    # Checks to see if we are on the Login page and do nothing
    if request.fullpath.include?(login_path)
      @path_check = '@path_check request.fullpath.include?(login_path)'
    else
      @popsicle = 'Popsicle'
      if has_cookie?
        # do nothing
        'has_cookie You have a valid cookie that is allowing you to browse the Sinai Digital Library.'
      elsif has_token?
        # user has a token so we then need to set the cookie based on the fact that they have a token in the database
        set_cookie
        'has_token You have a valid cookie that is allowing you to browse the Sinai Digital Library.'
      else
        redirect_to "/login?callback=#{@original_url}"
      end
    end
  end

  def has_token?
    # Does user have the sinai token in the database?
    params[:token].present? && Login.find_by(token: params[:token])
  end

  def set_cookie

    cookies[:sinai_authenticated] = {
      value: true,
      expires: Time.now + 90.days,
      domain: ENV['DOMAIN']
    }
    @cookie_created = 'Cookie created'
  end

  def has_cookie?
    # Does user have the sinai cookie set to true?
    @has_cookie = cookies[:sinai_authenticated]
  end
end
