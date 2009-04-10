class Album < ActiveRecord::Base
  include Settings
	ajaxful_rateable :stars => 5
	acts_as_taggable_on :tags
	
  default_scope :order => 'begin_on desc'

  after_create :create_picture_directory
  after_destroy :delete_picture_directory
  before_update :save_old_dirname
  after_update :update_picture_directory


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
	validate :uniq_title_in_one_year

  ######################################################
  ##### method
  ######################################################
	def self.year_range
    self.all.map(&:begin_on).map(&:year).uniq
  end
	
	def self.find_by_year_or_condition_with_order(title, year, order, type = nil)
    order = 'begin_on desc' if order.blank?
    if order.include?(',')
      type, temp_order = order.split(',')
      order = 'begin_on desc'
    end
		if year.blank?
			albums = self.all(:order => order, :conditions => ['title like ?', "%#{title}%"])
		else
			date = Date.civil(year.to_i)
		  albums = self.all(:conditions => ['begin_on >= ? and begin_on <= ? and title like ?', date.beginning_of_year, date.end_of_year, "%#{title}%"], :order => order)
	  end
    unless type.blank?
      albums = albums.sort_by{|album| eval('album.'+type+'.size')}
      albums.reverse! if temp_order == 'desc'
    end
    return albums
	end
	
	private
  attr_accessor :old_dirname

	def must_be_valid_range
		if not begin_on.blank? and not end_on.blank? and begin_on > end_on
			errors.add(:end_on, "date range error!")
		end
	end
	
	def uniq_title_in_one_year
		if new_record? and Album.exists?(['title = ? and begin_on >= ? and end_on <= ?', title, begin_on.beginning_of_year, begin_on.end_of_year])
			errors.add(:title, "has already been userd in year #{begin_on.year}!")
		end
	end

  def create_picture_directory
    Dir.mkdir(PIC_DIR + begin_on.year.to_s) unless File.directory?(PIC_DIR + begin_on.year.to_s)
    Dir.mkdir(PIC_DIR + begin_on.year.to_s+'/'+begin_on.to_s(:number)+title)
  end

  def delete_picture_directory
    FileUtils.rm_rf(PIC_DIR+begin_on.year.to_s+'/'+begin_on.to_s(:number)+title)
    unless Album.exists?(['begin_on >= ? and end_on <= ?', begin_on.beginning_of_year, begin_on.end_of_year])
      FileUtils.rm_rf(PIC_DIR+begin_on.year.to_s)
    end
  end
  
  def save_old_dirname
    old_album = Album.find(id)
    self.old_dirname = old_album.begin_on.to_s(:number)+old_album.title
  end
  
  def update_picture_directory
    new_dirname = begin_on.to_s(:number)+title
    unless old_dirname == new_dirname
      File.rename(PIC_DIR+begin_on.year.to_s+'/'+old_dirname, PIC_DIR+begin_on.year.to_s+'/'+new_dirname)
    end
  end
end
