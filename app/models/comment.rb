class Comment < ActiveRecord::Base

  default_scope :order => 'created_at desc'

  ######################################################
  ##### association
  ######################################################
	belongs_to :commentable, :polymorphic => true
	
  ######################################################
  ##### validation
  ######################################################
  validates_presence_of :name, :email, :content, :commentable_type, :commentable_id
  validates_as_email_address :email
  
  
end
