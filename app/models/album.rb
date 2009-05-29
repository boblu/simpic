class Album < ActiveRecord::Base
	simpic_rateable :stars => 5
	acts_as_taggable_on :tags
	
  default_scope :order => 'begin_on desc, created_at desc'
	named_scope :published, :conditions => {:publish => true}
  named_scope :authority, lambda{|auth_level| {:conditions => ['read_level >= ?', auth_level.to_i]}}
  named_scope :year, lambda{|year|
  	date = Date.civil(year.to_i)
  	{:conditions => ['begin_on >= ? and begin_on <= ?', date.beginning_of_year, date.end_of_year]}
  }
  named_scope :order, lambda{|order| {:order => order}}

  before_create :create_picture_directory
  before_update :update_picture_directory, :check_read_level
  after_destroy :delete_picture_directory

  ######################################################
  ##### association
  ######################################################
	has_many :contents, :dependent => :destroy
	has_many :pictures, :class_name => 'Content', :foreign_key => 'album_id', :conditions => "content_type='picture'"
	has_many :videos, :class_name => 'Content', :foreign_key => 'album_id', :conditions => "content_type='video'"
	has_many :comments, :as => :commentable, :dependent => :destroy

  ######################################################
  ##### validation
  ######################################################
	validates_presence_of :title, :title_meta, :begin_on, :end_on, :appearance, :read_level
	validate :must_be_valid_range
	validate :uniq_title_meta_in_one_year

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
			albums = self.order(order).find(:all, :conditions => ['title like ?', "%#{title}%"])
		else
			albums = self.year(year).order(order).find(:all, :conditions => ['title like ?', "%#{title}%"])
	  end
    unless type.blank?
      albums = albums.sort_by{|album| eval('album.'+type+'.size')}
      albums.reverse! if temp_order == 'desc'
    end
    return albums
	end

	def year
		begin_on.year.to_s
	end

	def dirname
		begin_on.to_s(:number) + title_meta
	end

	def path
		year + '/' + dirname
	end
	
	def update_attributes!(options)
		options = options.update({:updated_at => Time.now})
		super(options)
	end
	
	def self.find_by_dirname(temp_dirname)
		self.find(:first, :conditions => {:title_meta => temp_dirname[8..-1], :begin_on => temp_dirname[0..7]})
	end
	
	private

  def must_be_valid_range
		if not begin_on.blank? and not end_on.blank? and begin_on > end_on
			errors.add(:end_on, "date range error!")
		end
	end
	
	def uniq_title_meta_in_one_year
		if new_record? and Album.exists?(['title_meta = ? and begin_on >= ? and end_on <= ?', title_meta, begin_on.beginning_of_year, begin_on.end_of_year])
			errors.add(:title_meta, "has already been userd in year #{begin_on.year}!")
		end
	end

  def create_picture_directory
  	create_year_directory(year)
    temp = eval(App.first.settings["pic_dir"])
    Dir.mkdir(temp + 'original/' + path)
    Dir.mkdir(temp + 'normal/' + path)
    Dir.mkdir(temp + 'medium/' + path)
    Dir.mkdir(temp + 'thumbnail/' + path)
  end
	
	def create_year_directory(temp_year = nil)
    temp = eval(App.first.settings["pic_dir"])
    Dir.mkdir(temp + 'original/' + temp_year) unless File.directory?(temp + 'original/' + temp_year)
    Dir.mkdir(temp + 'normal/' + temp_year) unless File.directory?(temp + 'normal/' + temp_year)
    Dir.mkdir(temp + 'medium/' + temp_year) unless File.directory?(temp + 'medium/' + temp_year)
    Dir.mkdir(temp + 'thumbnail/' + temp_year) unless File.directory?(temp + 'thumbnail/' + temp_year)
	end
	
	def check_read_level
		old_album = Album.find(id)
		if old_album.read_level > read_level
			old_album.contents.authority(read_level).update_all("read_level = #{read_level}")
		end
	end

  def update_picture_directory
    old_album = Album.find(id)
    old_dirname = old_album.begin_on.to_s(:number) + old_album.title_meta
    new_dirname = begin_on.to_s(:number) + title_meta
    unless old_dirname == new_dirname
    	if old_album.year == year
    		rename_album_dirname(:old_year => year, :old_dirname => old_dirname, :new_year => year, :new_dirname => new_dirname)
      else
      	create_year_directory(year)
      	rename_album_dirname(:old_year => old_album.year, :old_dirname => old_dirname, :new_year => year, :new_dirname => new_dirname)
      end
    end
  end
  
  def rename_album_dirname(options)
    temp = eval(App.first.settings["pic_dir"])
    File.rename(temp + 'original/' + options[:old_year] + '/' + options[:old_dirname], temp + 'original/' + options[:new_year] + '/' + options[:new_dirname])
    File.rename(temp + 'normal/' + options[:old_year] + '/' + options[:old_dirname], temp + 'normal/' + options[:new_year] + '/' + options[:new_dirname])
	  File.rename(temp + 'medium/' + options[:old_year] + '/' + options[:old_dirname], temp + 'medium/' + options[:new_year] + '/' + options[:new_dirname])
  	File.rename(temp + 'thumbnail/' + options[:old_year] + '/' + options[:old_dirname], temp + 'thumbnail/' + options[:new_year] + '/' + options[:new_dirname])
  end
  
  def delete_picture_directory
    temp = eval(App.first.settings["pic_dir"])
    FileUtils.rm_rf(temp + 'original/' + path)
    FileUtils.rm_rf(temp + 'normal/' + path)
    FileUtils.rm_rf(temp + 'medium/' + path)
    FileUtils.rm_rf(temp + 'thumbnail/' + path)
    unless Album.exists?(['begin_on >= ? and end_on <= ?', begin_on.beginning_of_year, begin_on.end_of_year])
      FileUtils.rm_rf(temp + 'original/' + year)
      FileUtils.rm_rf(temp + 'normal/' + year)
      FileUtils.rm_rf(temp + 'medium/' + year)
      FileUtils.rm_rf(temp + 'thumbnail/' + year)
    end
  end
end
