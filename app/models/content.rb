require 'digest/sha1'
require 'image_science'
require 'mini_exiftool'
require 'mime/types'

class Content < ActiveRecord::Base
  include Settings
	simpic_rateable :stars => 5
	acts_as_taggable_on :tags

  default_scope :order => 'display_order asc'
  named_scope :authority, lambda{|auth_level| {:conditions => ['read_level >= ?', auth_level.to_i]}}
  named_scope :covered, :conditions => {:top_shown => true}, :order => "rating_average desc"
  named_scope :authority_filter, lambda{|auth_level| {:conditions => ['read_level = ?', auth_level.to_i]}}
	
  before_create :arrange_inside_order, :create_picture, :set_read_level
  before_update :update_exif_datetimeoriginal
  after_save :update_album
  after_create :remove_temp_picture
  after_destroy :delete_picture, :update_album
	
  ######################################################
  ##### association
  ######################################################
	belongs_to :album
	has_many :comments, :as => :commentable, :dependent => :destroy

  ######################################################
  ##### validation
  ######################################################
  HUMANIZED_ATTRIBUTES = { :token_time => "Token at" }
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  validates_presence_of :content_type, :album_id, :filename, :token_time, :read_level, :display_order
  
  def uploaded?
  	@uploaded_from_client
  end
  
  def temp_filename
  	@temp_filename
  end
  
  def temp_filename=(tfn)
  	@temp_filename = tfn
  	@uploaded_from_client = false
  	self.filename = Digest::SHA1.hexdigest(tfn + 'simpic' + Time.now.to_s) + File.extname(TMP_PIC_DIR + tfn).downcase
  	self.token_time = MiniExiftool.new(TMP_PIC_DIR + tfn).datetimeoriginal || Time.now
  end
  
  def original_path
  	PIC_DIR + 'original/' + album.path + '/' + filename
  end
  
  def normal_path
  	PIC_DIR + 'normal/' + album.path + '/' + filename
  end
  
  def medium_path
  	PIC_DIR + 'medium/' + album.path + '/' + filename
  end
  
  def thumb_path
  	PIC_DIR + 'thumbnail/' + album.path + '/' + filename
  end
  
  def normal_url
    '/' + File.basename(PIC_DIR) + '/normal/' + album.path + '/' + filename
  end
  
  def medium_url
    '/' + File.basename(PIC_DIR) + '/medium/' + album.path + '/' + filename
  end
  
  def thumb_url
  	'/' + File.basename(PIC_DIR) + '/thumbnail/' + album.path + '/' + filename
  end
  
  def swf_uploaded_picture=(filedata)
  	@uploaded_from_client = true
		filedata.content_type = MIME::Types.type_for(filedata.original_filename)
		self.content_type = 'picture'
		self.filename = Digest::SHA1.hexdigest(filedata.original_filename + 'simpic' + Time.now.to_s) + File.extname(filedata.original_filename).downcase
		File.open(original_path, "wb") {|f| f.write(filedata.read)}
		self.token_time = MiniExiftool.new(original_path).datetimeoriginal || Time.now
  end
  
  private
  
  def arrange_inside_order
    sibling_pictures = Album.find(album_id).pictures
    (self.display_order = sibling_pictures.map(&:display_order).max + 1) unless sibling_pictures.blank?
  end
  
  def create_picture
	 	FileUtils.cp(TMP_PIC_DIR + temp_filename, original_path) unless uploaded?
    ImageScience.with_image(original_path) do |img|
    	if img.width >= img.height and img.width > NORMAIL_SIZE[0]
    		img.thumbnail(NORMAIL_SIZE[0]){|thumb| thumb.save(normal_path)}
    	elsif img.width < img.height and img.height > NORMAIL_SIZE[1]
    		img.thumbnail(NORMAIL_SIZE[1]){|thumb| thumb.save(normal_path)}
    	else
				FileUtils.cp(original_path, normal_path)
      end
    	if img.width >= img.height and img.width > MEDIUM_SIZE[0]
    		img.thumbnail(MEDIUM_SIZE[0]){|thumb| thumb.save(medium_path)}
    	elsif img.width < img.height and img.height > MEDIUM_SIZE[1]
    		img.thumbnail(MEDIUM_SIZE[1]){|thumb| thumb.save(medium_path)}
    	else
				FileUtils.cp(original_path, medium_path)
      end
    	if img.width >= img.height and img.width > THUMB_SIZE[0]
    		img.thumbnail(THUMB_SIZE[0]){|thumb| thumb.save(thumb_path)}
    	elsif img.width < img.height and img.height > THUMB_SIZE[1]
    		img.thumbnail(THUMB_SIZE[1]){|thumb| thumb.save(thumb_path)}
    	else
				FileUtils.cp(original_path, thumb_path)
      end
    end
  end
  
  def update_exif_datetimeoriginal
    if content_type == 'picture'
      unless Content.find(id).token_time == token_time
        [original_path, normal_path, medium_path, thumb_path].each{|img|
          temp = MiniExiftool.new(img)
          temp.datetimeoriginal = token_time
          temp.save
        }
      end
    end
  end
  
  def delete_picture
    FileUtils.rm_rf(original_path)
    FileUtils.rm_rf(normal_path)
    FileUtils.rm_rf(medium_path)
    FileUtils.rm_rf(thumb_path)
  end
  
  def update_album
  	album.update_attributes!(:updated_at => Time.now)
  end
  
  def set_read_level
  	self.read_level = album.read_level
  end
  
  def remove_temp_picture
  	FileUtils.rm_rf(TMP_PIC_DIR + @temp_filename) unless uploaded?
  end
end
