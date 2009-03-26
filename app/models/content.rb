class Content < ActiveRecord::Base
	ajaxful_rateable :stars => 5
	
  ######################################################
  ##### association
  ######################################################
	belongs_to :album
	has_many :comments, :as => :commentable

  ######################################################
  ##### validation
  ######################################################
  validates_presence_of :content_type, :album_id, :normal_path, :token_time, :read_level, :order, :top_shown
  validates_presence_of :thumb_path, :if => "content_type == 'picture'"
end
