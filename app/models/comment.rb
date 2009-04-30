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
  
  def self.authority_latest(auth_level)
  	return self.all.inject([]){|latest, comment|
  		return latest if latest.size >= 5
  		latest << comment if comment.commentable.read_level >= auth_level
  	}
  end
end
