class SessionsController < ApplicationController
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == "1" ? remember(@user) : forget(@user)
        redirect_back_or(@user)
      else
        message = "Account not activated. "
        message += "Check your email for the activatoin link."
        flash[:warning] = message
        redirect_to root_url
      end
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
