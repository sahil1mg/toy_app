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
end
