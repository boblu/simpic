require 'test_helper'

class ContentTest < ActiveSupport::TestCase
  test 'new content' do
  	content = Content.new
  	
  	assert !content.valid?
  	assert !content.errors.invalid?(:content_type)
  	assert content.errors.invalid?(:album_id)
  	assert content.errors.invalid?(:thumb_path)
  	assert content.errors.invalid?(:normal_path)
  	assert content.errors.invalid?(:token_time)
  	assert !content.errors.invalid?(:read_level)
  	assert content.errors.invalid?(:order)
  	assert !content.errors.invalid?(:top_shown)
  	
  	content.album_id = 1
  	content.thumb_path = '/home'
  	content.normal_path = '/home'
  	content.token_time = "20081009"
  	content.order = 1
  	assert content.valid?
  	
  	content.content_type = "video"
  	content.thumb_path = nil
  	assert content.valid?
  end
end
