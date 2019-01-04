require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

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

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password"}}
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
