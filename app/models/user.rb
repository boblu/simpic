class User < ActiveRecord::Base
	ajaxful_rater
	
  ######################################################
  ##### validation
  ######################################################
  validates_presence_of :user_type, :hashed_password, :read_level, :span
  validates_as_email_address :email, :allow_nil => true
  
end
