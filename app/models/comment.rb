class Comment < ActiveRecord::Base
  ######################################################
  ##### association
  ######################################################
	belongs_to :commentable, :polymorphic => true
	
  ######################################################
  ##### validation
  ######################################################
  validates_presence_of :name, :email, :content
  validates_as_email_address :email
end
