require 'test_helper'

class CommentTest < ActiveSupport::TestCase
	test 'new comment' do
  	comment = Comment.new
  	
  	assert !comment.valid?
  	assert comment.errors.invalid?(:name)
  	assert comment.errors.invalid?(:email)
  	assert comment.errors.invalid?(:content)
  	
  	comment.name = "dfsafda"
  	comment.email = "aaaaaaaaaa"
  	comment.content = "bbbbbbbbb"
  	assert !comment.valid?
  	assert comment.errors.invalid?(:email)
  	
  	comment.email = 'boblu@jiaeil.com'
  	assert comment.valid?
  end
end
