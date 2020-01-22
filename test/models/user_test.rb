require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name:"User", email:"user@example.com", password:"foobar", password_confirmation:"foobar")
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be unique(Case Insensitivity test)" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "check email address is downcased before saving" do 
    duplicate_user = @user.dup
    duplicate_user.email = "USER@EXAMPLE.COM"
    duplicate_user.save
    assert_not_equal "USER@EXAMPLE.COM", duplicate_user.reload.email
  end

  test "password should be present (non blank)" do
    @user.password = @user.password_confirmation =" "*6
    assert_not @user.valid?
  end

  test "password should have minimum length" do
    @user.password  = @user.password_confirmation = "a"*5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end

    test "should follow and unfollow a user" do
      michael = users(:michael)
      archer  = users(:archer)
      assert_not michael.following?(archer)
      michael.follow(archer)
      assert michael.following?(archer)
      assert archer.followers.include?(michael)
      michael.unfollow(archer)
      assert_not michael.following?(archer)
    end
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # Posts from self
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
