class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  def hello
    render html: "hello World"
  end

  #Check if User is logged in, that only let them access protected page
  def logged_in_user
    unless logged_in?
      store_location #coming from which URL
      flash[:danger] = "Kindly Log In"
      redirect_to login_url
    end
  end

end
