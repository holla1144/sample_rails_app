require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect from edit when not logged in" do
    get edit_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect update submission when not logged in" do
    patch user_path(@user), params: { user: {
                                          name: @user.name,
                                          email: @user.email }}

    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect from edit if incorrect user" do
    log_in_as @other_user
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect attempt to update data when logged in as incorrect user" do
    log_in_as @other_user
    patch user_path(@user), params: { user: {
                                              name: "New Name",
                                              email: "new@email.com" }}
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect from index to login_url when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be editable through the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user:
                                            { password: '',
                                              password_confirmation: '',
                                              admin: true }}

    assert_not  @other_user.reload.admin?
  end

  test "should redirect when attempting to destroy a user while not logged in" do
    assert_no_difference "User.count" do
      delete user_path(@other_user)
    end

    assert_redirected_to login_url
  end

  test "should redirect when delete request sent as non-admin user" do
    log_in_as(@other_user)
    assert_no_difference "User.count" do
      delete user_path(@user)
    end

    assert_redirected_to root_url
  end

  test "delete successfully when user is admin" do
    log_in_as(@user)
    assert_difference "User.count", -1 do
      delete user_path(@other_user)
    end

    assert_redirected_to users_url
  end

  test "should redirect from following when user not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
