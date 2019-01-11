class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      remember user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination' # show error messages
      render 'new'
    end
  end

  def new
    render 'new'
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
