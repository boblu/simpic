require 'digest/sha1'
require 'image_science'
require 'mini_exiftool'

class Content < ActiveRecord::Base
  include Settings
	ajaxful_rateable :stars => 5
	acts_as_taggable_on :tags

  default_scope :order => 'display_order asc'

  before_create :arrange_inside_order
  after_create :create_picture
  after_destroy :delete_picture
	
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
  
  def temp_filename
  	@temp_filename
  end
  
  def temp_filename=(tfn)
  	@temp_filename = tfn
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
  
  def medium_url
    '/' + File.basename(PIC_DIR) + '/medium/' + album.path + '/' + filename
  end
  
  def thumb_url
  	'/' + File.basename(PIC_DIR) + '/thumbnail/' + album.path + '/' + filename
  end
  
  private
  
  def arrange_inside_order
    sibling_pictures = Album.find(album_id).pictures
    (self.display_order = sibling_pictures.map(&:display_order).max + 1) unless sibling_pictures.blank?
  end
  
  def create_picture
  	FileUtils.cp(TMP_PIC_DIR + temp_filename, original_path)
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
  
  def delete_picture
    FileUtils.rm_rf(original_path)
    FileUtils.rm_rf(normal_path)
    FileUtils.rm_rf(medium_path)
    FileUtils.rm_rf(thumb_path)
  end
end
