class SessionsController < ApplicationController
  def new
  end

  def create
    respond_to do |format| #if respond_to is used then format has to be used to get next page
      user = User.find_by(email: params[:session][:email].downcase)
      if user && user.authenticate(params[:session][:password])
        log_in user
        format.html{ redirect_to user, notice: 'Welcome back' }
      else
        flash.now[:danger]="Wrong Username and password"
        format.html{ render 'new'}
      end
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
