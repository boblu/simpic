class Album < ActiveRecord::Base
	has_many :contents
	has_many :pictures, :class_name => 'Content', :foreign_key => 'album_id', :conditions => 'type=0'
	has_many :videos, :class_name => 'Content', :foreign_key => 'album_id', :conditions => 'type=1'
	has_many :comments, :as => :commentable
end
