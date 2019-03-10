require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # this code is not idiomatically correct
    @micropost = Micropost.new(content: "Lorem Ipsum", user_id: @user.id)
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "should not be valid" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = ""
    assert_not @micropost.valid?
  end

  test "content less than or equal to 140 charachters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
end
