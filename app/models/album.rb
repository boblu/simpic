class Album < ActiveRecord::Base
	ajaxful_rateable :stars => 5
	
  default_scope :order => 'begin_on desc'

  ######################################################
  ##### association
  ######################################################
	has_many :contents
	has_many :pictures, :class_name => 'Content', :foreign_key => 'album_id', :conditions => "content_type='picture'"
	has_many :videos, :class_name => 'Content', :foreign_key => 'album_id', :conditions => "content_type='video'"
	has_many :comments, :as => :commentable

  ######################################################
  ##### validation
  ######################################################
	validates_presence_of :title, :begin_on, :end_on, :appearance, :read_level
	validate :must_be_valid_range

  ######################################################
  ##### method
  ######################################################
	def self.year_range
    self.all.map(&:begin_on).map(&:year).uniq
  end
	
	def self.find_by_year_and_order(year, order, type = nil)
    order = 'begin_on desc' if order.blank?
    if order.include?(',')
      type, temp_order = order.split(',')
      order = 'begin_on desc'
    end
		if year.blank?
			albums = self.all(:order => order)
		else
			date = Date.civil(year.to_i)
		  albums = self.all(:conditions => ['begin_on >= ? and begin_on <= ?', date.beginning_of_year, date.end_of_year], :order => order)
	  end
    unless type.blank?
      albums = albums.sort_by{|album| eval('album.'+type+'.size')}
      albums.reverse! if temp_order == 'desc'
    end
    return albums
	end
	
	private
	
	def must_be_valid_range
		errors.add_to_base("Date range error!") if begin_on > end_on
	end
end
