require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:lana)
    @admin_user = users(:michael)
    @non_admin_user = users(:archer)
    @non_activated_user = users(:krieger)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select   'div.pagination', count: 2
    User.where(activated: true).paginate(page:1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin_user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin_user
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    assert_difference "User.count", -1 do
      delete user_path(@non_admin_user)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin_user)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "non-activated users do not appear in users index" do
    log_in_as(@user)
    get users_path
    assert_select 'a[href=?]', user_path(@non_activated_user), text: @non_activated_user.name, count: 0
  end

  test "can't view individual users before they are activated" do
    log_in_as(@user)
    get user_path(@non_activated_user)
    assert_redirected_to root_url
  end
end
