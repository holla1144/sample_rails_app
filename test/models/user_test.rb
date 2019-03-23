require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "test_password", password_confirmation: "test_password")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "   "
    assert_not @user.valid?
  end

  test "name should not be longer than 50 characters" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be longer than 255 characters" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "eamil validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]

    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid" # This is a custom error message
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@barbaz...com foo@bar+baz.com]

    invalid_addresses.each do |address|
      @user.email = address
      assert_not @user.valid?, "#{address.inspect} should not be valid" # This is a custom error message
    end
  end

  test "user should be unique" do
    duplicate_user = @user.dup
    @user.save # saves the user created before each test is run
    assert_not duplicate_user.valid?
  end

  test "user email addresses should be unique (case insensitive)" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "user email is downcased before being persisted" do
    mixed_case_email = "Foo@ExAMPle.com"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (non blank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length of 6 characters" do
    @user.password = @user.password_confirmation = "a" * 5 # multiple assignment
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "deletes microposts when user destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem Ipsum")

    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow users" do
    michael = users(:michael)
    archer = users(:archer)

    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end

  test "Feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)

    # posts from followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end

    # posts from self
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end

    # posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
