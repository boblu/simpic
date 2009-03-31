class Album < ActiveRecord::Base
	ajaxful_rateable :stars => 5
	
  default_scope :order => 'begin_on desc'

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
	
  ######################################################
  ##### validation
  ######################################################
	def self.year_range
		self.all.map(&:begin_on).map(&:year).uniq
	end
	
	def self.find_by_year(year)
		if year.blank?
			self.all
		else
			date = Date.civil(year.to_i)
			self.all(:conditions => ['begin_on >= ? and begin_on <= ?', date.beginning_of_year, date.end_of_year])
		end
	end
end
