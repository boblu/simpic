class User < ActiveRecord::Base
	default_scope :order => 'updated_at desc'

	ajaxful_rater

  ######################################################
  ##### validation
  ######################################################
  validates_presence_of :read_level, :span, :password
  
  HUMANIZED_ATTRIBUTES = { :hashed_password => "Password" }
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  validates_uniqueness_of :hashed_password
  
  ######################################################
  ##### method
  ######################################################
  def self.authenticate(password)
  	user = self.find_by_hashed_password(self.encrypt_password(password))
    user = nil unless user
    return user
  end

  def password
  	@password.blank? ? decrypt_password : @password
  end
  
  def password=(pwd)
  	@password = pwd
  	self.hashed_password = User.encrypt_password(pwd)
  end
  
  def self.find_by_read_level_with_order(read_level, order)
    order = 'updated_at desc' if order.blank?
		if read_level.blank?
			users = self.all(:order => order)
		else
		  users = self.all(:conditions => ['read_level = ?', read_level], :order => order)
	  end
  end

  private
  
  def self.encrypt_password(pwd)
  	(pwd + 'simpic').unpack('H*')[0]
  end

  def decrypt_password
  	[self.hashed_password].pack('H*')[0..-7]
  end
end
