require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'new user' do
  	user = User.new
  	
  	assert !user.valid?
  	assert !user.errors.invalid?(:user_type)
  	assert user.errors.invalid?(:hashed_password)
  	assert !user.errors.invalid?(:read_level)
  	assert !user.errors.invalid?(:span)
  	
  	user.hashed_password = "dfsafda"
  	assert user.valid?
  	
  	user.email = "aaa"
  	assert !user.valid?
  	assert user.errors.invalid?(:email)
  	
  	user.email = "boblu@jiaeil.com"
  	assert user.valid?
  end
end
