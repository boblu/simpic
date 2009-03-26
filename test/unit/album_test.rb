require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
	test 'new album' do
  	album = Album.new
  	
  	assert !album.valid?
  	assert album.errors.invalid?(:title)
  	assert album.errors.invalid?(:begin_on)
  	assert album.errors.invalid?(:end_on)
  	assert !album.errors.invalid?(:appearance)
  	assert !album.errors.invalid?(:read_level)
  	
  	album.title = "dfsafda"
  	album.begin_on = "20081001"
  	album.end_on = "20081002"
  	assert album.valid?
  end
end
