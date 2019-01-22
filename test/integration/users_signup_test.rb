require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information does not produce new user" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {
          name: '',
          email: 'user@invalid',
          password: 'dude',
          password_confirmation: 'dude'
      }}
    end
    assert_template 'users/new'
  end

  test "invalid signup information yields error messages" do
    get signup_path
    post users_path, params: { user: {
        name: '',
        email: 'user@invalid',
        password: 'dude',
        password_confirmation: 'dude'
    }}

    assert_select "div[id=error_explanation]", count: 1
    assert_select "div.alert.alert-danger", text: "The form contains 3 errors."
    assert_select "div#error_explanation>ul>li", count: 3
    assert_select "div#error_explanation>ul>li:first-child", text: "Name can't be blank"
    assert_select "div#error_explanation>ul>li:nth-child(2)", text: "Email is invalid"
    assert_select "div#error_explanation>ul>li:nth-child(3)", text: /password is too short/i
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password"}}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # try to log in before activation
    log_in_as(user)
    assert_not is_logged_in?
    # invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # valid token, wrong mail
    get edit_account_activation_path(user.activation_token, email: "wrong!")
    assert_not is_logged_in?
    # valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
