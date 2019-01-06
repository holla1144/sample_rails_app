module SessionsHelper
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
  # logs in a user
  def log_in(user)
    session[:user_id] = user.id
  end

  # Returns true if user is logged in, false otherwise
  def logged_in?
    !current_user.nil?
  end
end
