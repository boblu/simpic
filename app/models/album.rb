class Album < ActiveRecord::Base
	ajaxful_rateable :stars => 5
	
  ######################################################
  ##### association
  ######################################################
	has_many :contents
	has_many :pictures, :class_name => 'Content', :foreign_key => 'album_id', :conditions => 'type=0'
	has_many :videos, :class_name => 'Content', :foreign_key => 'album_id', :conditions => 'type=1'
	has_many :comments, :as => :commentable

  ######################################################
  ##### validation
  ######################################################
	validates_presence_of :title, :begin_on, :end_on, :appearance, :read_level

end
