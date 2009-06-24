class User < ActiveRecord::Base
	default_scope :order => 'updated_at desc'

	simpic_rater

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

	def update_property(option={})
		if option[:read_level] == "0"
    	option[:span] = 0
   		option[:end_time] = nil
   	elsif option[:reset_span] == 'true' and not option[:span].blank?
   		if option[:span].to_i > self.span
	    	option[:end_time] = (self.end_time || Time.now) + (option[:span].to_i - self.span)*60
    	else
    		option[:end_time] = self.end_time - (self.span - option[:span].to_i)*60
    	end
   	end
   	option.delete("reset_span")
    self.update_attributes!(option)
	end

  private
  
  def self.encrypt_password(pwd)
  	(pwd + 'simpic').unpack('H*')[0]
  end

  def decrypt_password
  	[self.hashed_password].pack('H*')[0..-7]
  end
end


# ok 1. usr登陆后，根据time_span来设置end_time。
# ok 2. user 每次访问的一个action的时候，都对time_span做一下更新; layout中的count_down用end_time做参数
# ok 3. 如果user点击logout，设置end_time为nil,然后更新time_span。
# ok 4. 如果user直接关闭页面，则没有办法做任何事情。
# 5. 如果user下次访问时，session还没有过期的话，则需要检查end_time是否过期，如过期，则需要redirect
# ok 6. 如果user下次访问时，session已过期，即需要login时，检查time_span，重新设置end_time。
# 7. 页面中的count_down到期间时，进行redirect。
